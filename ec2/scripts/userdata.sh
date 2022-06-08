#!/bin/bash
set -e -o pipefail

# required settings
NODE_NAME_PREFIX="aws-chef-lab" # prefix the node name with the role of the node, e.g. webserver or rails-app-server

EC2_TOKEN=$(curl --silent --show-error --retry 3 -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
NODE_NAME="${NODE_NAME_PREFIX}$(curl --silent --show-error --retry 3 -H "X-aws-ec2-metadata-token: $EC2_TOKEN" http://169.254.169.254/latest/meta-data/instance-id)" # this uses the EC2 instance ID as the node name
CHEF_SERVER_NAME="MyChefAutomate" # The name of your Chef Server
CHEF_SERVER_ENDPOINT="mychefautomate-f1ojwu9mgw069v80.eu-west-1.opsworks-cm.io" # The FQDN of your Chef Server
REGION="eu-west-1" # Region of your Chef Server (Choose one of our supported regions - us-east-1, us-east-2, us-west-1, us-west-2, eu-central-1, eu-west-1, ap-northeast-1, ap-southeast-1, ap-southeast-2)
CHEF_CLIENT_VERSION="14.11.21" # latest if empty
CHEF_CLIENT_LOG_LOCATION="/var/log/chef-client.log"
CHEF_CLIENT_OPTS="-L ${CHEF_CLIENT_LOG_LOCATION}"

# optional settings
ROOT_CA_URLS=(https://opsworks-cm-${REGION}-prod-default-assets.s3.amazonaws.com/misc/opsworks-cm-ca-2016-root.pem https://opsworks-cm-${REGION}-prod-default-assets.s3.amazonaws.com/misc/opsworks-cm-ca-2020-root.pem ) # URL to download the Root CA certificate of your Chef Automate server. Change this only if you are using a server with a custom domain.
CHEF_ORGANIZATION="default" # AWS OpsWorks for Chef Server always creates the organization "default"
NODE_ENVIRONMENT="" # E.g. development, staging, onebox, ...
RUN_LIST="" # optional, only when not using Policy
JSON_ATTRIBUTES="" # optional, path to a json file for your node object

# extra optional settings
AWS_CLI_EXTRA_OPTS=()
CFN_SIGNAL=""

# required settings to define your node configuration

# In the example of our Starterkit we are using a policy for your node defined in Policyfile.rb
# To follow our example from the README.md leave RUN_LIST empty

mkdir -p "/etc/chef"

# when run-list is empty we will use json attributes according to our Policyfile.rb
if [ -z $RUN_LIST ]; then
  (cat <<-JSON
    {
      "name": "${NODE_NAME}",
      "chef_environment": "${NODE_ENVIRONMENT}",
      "policy_name": "opsworks-demo-webserver",
      "policy_group": "opsworks-demo"
    }
JSON
) | sed 's/: ""/: null/g' > /etc/chef/client-attributes.json
fi

# ---------------------------

AWS_CLI_TMP_FOLDER=$(mktemp --directory "/tmp/awscli_XXXX")
CHEF_TRUSTED_CERTS_PATH="/etc/chef/trusted_certs"
CHEF_CA_PATH="${CHEF_TRUSTED_CERTS_PATH}/rootca.pem"

prepare_os_packages() {
  local OS=`uname -a`
  if [[ ${OS} = *"Ubuntu"* ]]; then
    apt update && DEBIAN_FRONTEND=noninteractive apt -y upgrade
    apt -y install unzip python3 python3-pip
    pip3 install pystache==0.5.4
    # see: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-helper-scripts-reference.html
    pip3 install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-py3-latest.tar.gz
    ln -s /root/aws-cfn-bootstrap-latest/init/ubuntu/cfn-hup /etc/init.d/cfn-hup
    mkdir -p /opt/aws
    ln -s /usr/local/bin /opt/aws/bin
  fi
}

install_aws_cli() {
  # see: http://docs.aws.amazon.com/cli/latest/userguide/installing.html#install-bundle-other-os
  pushd "${AWS_CLI_TMP_FOLDER}"
  curl --show-error --retry 3 "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
}

aws_cli() {
  aws opsworks-cm --region "${REGION}" ${AWS_CLI_EXTRA_OPTS[@]:-} --output text "$@" --server-name "${CHEF_SERVER_NAME}"
}

associate_node() {
  local client_key="/etc/chef/client.pem"
  mkdir -p /etc/chef
  ( umask 077; openssl genrsa -out "${client_key}" 2048 )

  aws_cli associate-node \
    --node-name "${NODE_NAME}" \
    --engine-attributes \
      "Name=CHEF_AUTOMATE_ORGANIZATION,Value=${CHEF_ORGANIZATION}" \
      "Name=CHEF_AUTOMATE_NODE_PUBLIC_KEY,Value='$(openssl rsa -in "${client_key}" -pubout)'"
}

write_chef_config() {
  (
    echo "chef_server_url   'https://${CHEF_SERVER_ENDPOINT}/organizations/${CHEF_ORGANIZATION}'"
    echo "node_name         '${NODE_NAME}'"
    echo "trusted_certs_dir       '${CHEF_TRUSTED_CERTS_PATH}'"
    echo "chef_license      'accept'"
  ) >> /etc/chef/client.rb
}

install_chef_client() {
  # see: https://docs.chef.io/install_omnibus.html
  curl --silent --show-error --retry 3 --location https://omnitruck.chef.io/install.sh | bash -s -- -v "${CHEF_CLIENT_VERSION}"
}

install_trusted_certs() {
  mkdir -p ${CHEF_TRUSTED_CERTS_PATH}
  if [ ! -z "${ROOT_CA_URLS}" ]; then
    cd ${CHEF_TRUSTED_CERTS_PATH}
    for url in ${ROOT_CA_URLS[@]}; do
      curl --silent --show-error --retry 3 --location -O "${url}"
    done
    cd -
  fi
}

wait_node_associated() {
  aws_cli wait node-associated --node-association-status-token "$1"
}

# order of execution of functions
prepare_os_packages
install_aws_cli
install_chef_client
node_association_status_token="$(associate_node)"
write_chef_config
install_trusted_certs
wait_node_associated "${node_association_status_token}"

# initial chef-client run to register node

add_node_environment_to_client_opts() {
  if [ ! -z "${NODE_ENVIRONMENT}" ]; then
    CHEF_CLIENT_OPTS+=("-E ${NODE_ENVIRONMENT}");
  fi
}

add_json_attributes_to_client_opts() {
  if [ ! -z "${JSON_ATTRIBUTES}" ]; then
    echo "${JSON_ATTRIBUTES}" > /tmp/chef-attributes.json
    CHEF_CLIENT_OPTS+=("-j /tmp/chef-attributes.json")
  fi
}


# when the run-list is provided we use this for the chef-client run
if [ ! -z "${RUN_LIST}" ]; then
  # use a regular run_list to run chef
  CHEF_CLIENT_OPTS=(-r "${RUN_LIST}")
  add_node_environment_to_client_opts
  add_json_attributes_to_client_opts
else
  # use a node policy following the example of your Starterkit
  CHEF_CLIENT_OPTS=("-j /etc/chef/client-attributes.json")
fi

# initial chef-client run to register node
if [ ! -z "${CHEF_CLIENT_OPTS}" ]; then
  chef-client ${CHEF_CLIENT_OPTS[@]}
fi

touch /tmp/userdata.done
eval ${CFN_SIGNAL}
