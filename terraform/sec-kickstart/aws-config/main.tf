
locals {
  aws_region = var.aws_region != "" ? var.aws_region : data.aws_region.current.name

  # Max rule anme length is 64 chars. Currently the longest rule name is "cloudtrail-is-multi-region-enabled-${local.resource_name_suffix}".
  # Therefore length of resource_name_suffix cannot be higher than 29 chars, hence the call to substr.
  # The call to trimsuffix prevents ending the string on a '-' char
  resource_name_suffix = trimsuffix(substr("${var.project}-${var.environment}-${local.aws_region}", 0, 29), "-")

  config_bucket_name = var.bucket_name != "" ? var.bucket_name : "aws-config-bucket-${local.resource_name_suffix}"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
