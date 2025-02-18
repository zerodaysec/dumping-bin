locals {
  create_bucket = var.enabled && var.create_bucket
}

resource "aws_s3_bucket" "config_bucket" {
  count = local.create_bucket ? 1 : 0

  bucket = local.config_bucket_name

  force_destroy = var.bucket_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "config_bucket" {
  count = local.create_bucket && var.bucket_block_public_access ? 1 : 0

  bucket = join("", aws_s3_bucket.config_bucket[*].id)

  block_public_acls   = true
  block_public_policy = true
}
