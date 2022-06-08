resource "aws_instance" "wordpress" {
  ami           = var.ami_name # Amazon Linux in us-east-1, update as per your region
  instance_type = var.instance_type
  #iam_instance_profile ="${aws_iam_instance_profile.ec2_profile.name}"
  
  tags = {
    labs   = "ec2"
    number = "01"
    project ="chef"
    Name    = var.ec2_tag_name
  }
}