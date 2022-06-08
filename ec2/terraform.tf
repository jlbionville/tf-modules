terraform {
  required_version = ">= 1.0.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"      
    }
    
  }

}
provider "aws" {
  alias = "aws_ec2"
  profile= "admincs"
}