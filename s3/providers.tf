provider "aws" {
  alias   = "aws_ec2"
  profile = "admincs"


  default_tags {
    tags = {

      Name        = "made-with-terraform"
      environment = "all"
      project     = "labs"

    }
  }
}