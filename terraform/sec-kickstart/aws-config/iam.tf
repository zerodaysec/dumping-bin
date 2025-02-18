###################################################################################
# Role to be assumed by AWS Config
#
# with policies set according to
# https://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html
###################################################################################
locals {
  iam_service_role_name             = var.iam_service_role_name != "" ? var.iam_service_role_name : "aws-config-service-${local.resource_name_suffix}"
  iam_service_policy_name_prefix    = "aws-config-policy-${local.resource_name_suffix}"
  iam_service_s3_access_policy_name = "${local.iam_service_policy_name_prefix}-s3"

  aws_config_role_name = join("", aws_iam_role.aws_config[*].name)
  aws_config_role_arn  = join("", aws_iam_role.aws_config[*].arn)
}

resource "aws_iam_role" "aws_config" {
  count = var.enabled ? 1 : 0

  name = local.iam_service_role_name

  assume_role_policy = join("", data.aws_iam_policy_document.aws_config_assume_role_policy[*].json)

  tags = var.tags
}

data "aws_iam_policy_document" "aws_config_assume_role_policy" {
  count = var.enabled ? 1 : 0

  statement {
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    effect = "Allow"

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "managed_policy" {
  count = var.enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
  role       = local.aws_config_role_name
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  count = var.enabled ? 1 : 0

  role       = local.aws_config_role_name
  policy_arn = join("", aws_iam_policy.s3_access[*].arn)
}

resource "aws_iam_policy" "s3_access" {
  count = var.enabled ? 1 : 0

  name   = local.iam_service_s3_access_policy_name
  policy = data.aws_iam_policy_document.combined_policy.json
}

data "aws_iam_policy_document" "combined_policy" {

  source_policy_documents = concat(
    data.aws_iam_policy_document.s3_access[*].json,
    data.aws_iam_policy_document.kms_access[*].json
  )
}


data "aws_iam_policy_document" "s3_access" {
  count = var.enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]

    resources = ["arn:aws:s3:::${local.config_bucket_name}/${var.bucket_object_prefix != "" ? format("%s/", var.bucket_object_prefix) : ""}AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::${local.config_bucket_name}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${local.config_bucket_name}"
    ]
  }
}

data "aws_iam_policy_document" "kms_access" {
  count = var.enabled && length(var.aws_config_kms_arns) > 0 ? 1 : 0

  statement {
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    resources = var.aws_config_kms_arns
  }
}
