

variable "aws_region" {
  default = "us-west-2"
}

provider "aws" {
  region = var.aws_region
}

variable "bucket_name" {
  default = "company-tf-module-aws-config-managed-rules-complete-s3-kms"
}

module "aws_config" {
  source = "../../"

  create_bucket        = false
  bucket_name          = module.bucket.this_s3_bucket_id
  bucket_object_prefix = "config-test"
}

output "iam_password_check_policy" {
  value = module.aws_config.iam_password_check_policy
}

module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = var.bucket_name
  acl           = "log-delivery-write"
  force_destroy = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "AES256"
        kms_master_key_id = ""
      }
    }
  }
}
