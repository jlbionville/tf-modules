resource "aws_instance" "wordpress" {
  ami           = "ami-0d3c032f5934e1b41" # Amazon Linux in us-east-1, update as per your region
  instance_type = "t2.micro"
  #iam_instance_profile ="${aws_iam_instance_profile.ec2_profile.name}"
  key_name= "cloudshopping"
  tags = {
    labs   = "ec2"
    number = "01"
    project ="chef"
  }