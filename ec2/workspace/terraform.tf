terraform {
  required_version = ">=1.2.x"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.x"
    }
  }

}