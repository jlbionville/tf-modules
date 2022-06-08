resource "aws_instance" "wordpress" {
  ami           = var.ami_name # Amazon Linux in us-east-1, update as per your region
  instance_type = var.instance_type
  #iam_instance_profile ="${aws_iam_instance_profile.ec2_profile.name}"
#  key_name = ""
  tags = {
    labs    = "ec2"
    number  = "01"
    project = "chef"
    Name    = var.ec2_tag_name
  }

  # the VPC subnet
  # subnet_id = aws_subnet.main-public-1.id

  # the security group
  # vpc_security_group_ids = [aws_security_group.allow-ssh.id]
  # user_data = data.template_file.user_data.rendered
  # the public SSH key
  #key_name = aws_key_pair.mykeypair.key_name  

}

# resource "aws_iam_instance_profile" "ec2_profile" {
#   name = "ec2_profile"
#   role = "Role4EC2AccessS3"
# }