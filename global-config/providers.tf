provider "aws" {
  alias   = "aws_ec2"
  profile = var.aws_profile


  default_tags {
    tags = {

      Name        = "made-with-terraform"
      environment = "all"
      project     = "labs"

    }
  }
}