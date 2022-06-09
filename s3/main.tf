
module "global-configuration" {
  source = "/home/ubuntu/depots/tf-workspace/global-config"
  
} 
resource "aws_s3_bucket" "default_bucket" {
  bucket = local.bucket_name
}

locals {
  # faire un test pour prendre la surcharge => var.bucket_name
  bucket_name = format("%s-%s", var.company, var.project_name)
}