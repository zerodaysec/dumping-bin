locals {
  create_bucket = var.enabled && var.create_s3_bucket && var.is_guardduty_master && (local.has_ipset || local.has_threatintelset)

  bucket_name = var.s3_bucket_name != "" ? var.s3_bucket_name : "aws-guard-duty-${local.resource_name_suffix}"

  bucket_id = try(aws_s3_bucket.created[*].id, "NA")
}

resource "aws_s3_bucket" "created" {
  count = local.create_bucket ? 1 : 0

  bucket = local.bucket_name

  force_destroy = var.s3_bucket_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "created" {
  count = local.create_bucket ? 1 : 0

  bucket = local.bucket_id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_acl" "created" {
  count = local.create_bucket ? 1 : 0

  bucket = try(aws_s3_bucket.created[*].id, "NA")
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.created]
}

resource "aws_s3_bucket_public_access_block" "created_bucket" {
  count = local.create_bucket && var.s3_bucket_block_public_access ? 1 : 0

  bucket = one(aws_s3_bucket.created[*].id)

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
