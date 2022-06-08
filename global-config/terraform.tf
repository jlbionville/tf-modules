terraform {
  required_version = ">= 1.0.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

  }
  # backend "s3" {
  #   bucket = "alfaco-labs"
  #   key    = "labs/ec2/01/deployed.tfstate"
  #   acl    = "bucket-owner-full-control"
  # }
}

