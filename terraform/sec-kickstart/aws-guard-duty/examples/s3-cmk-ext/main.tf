terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "email" {
  default = "devex.bot@gmail.com"
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "master" {}

data "aws_caller_identity" "member" {}

module "aws_guard_duty_master" {
  source = "../../"

  project = "test"

  is_guardduty_master = true

  create_s3_bucket = false
  s3_bucket_name   = module.bucket.s3_bucket_id

  activate_ipset = true
  ipset_iplist   = ["8.8.8.8/32"]

  member_list = [{
    account_id   = data.aws_caller_identity.member.account_id
    member_email = var.email
    invite       = true
  }]
}

module "aws_guard_duty_member" {
  source = "../../"

  is_guardduty_member = true
  master_account_id   = module.aws_guard_duty_master.account_id
}

variable "bucket_name" {
  default = "FIXME-BUCKET"
}

module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = module.bucket_cmk.key_arn
      }
    }
  }

  object_lock_configuration = {
    object_lock_enabled = "Enabled"
    rule = {
      default_retention = {
        mode = "GOVERNANCE"
        days = 1
      }
    }
  }
}

module "bucket_cmk" {
  source = "git::https://gitlab.com/open-source-devex/terraform-modules/aws/kms-key.git?ref=v1.0.1"

  key_name        = var.bucket_name
  key_description = "CMK for S3 bucket ${var.bucket_name}"

  key_policy = [
    {
      principals = [
        {
          type        = "AWS",
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.master.account_id}:root"]
        },
      ]

      effect    = "Allow"
      actions   = ["kms:GenerateDataKey*"]
      resources = ["*"]
      condition = []
    },
  ]
}
