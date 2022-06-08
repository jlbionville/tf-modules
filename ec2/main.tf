# contains filter locals data
module "global-configuration" {
  source = "/home/ubuntu/depots/tf-workspace/global-config"
  
} 
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
