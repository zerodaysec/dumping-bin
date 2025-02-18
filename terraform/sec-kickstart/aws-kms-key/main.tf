locals {
  account_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"

  uuid            = random_uuid.name.result
  key_name        = var.key_name != null ? var.key_name : "osdevex/aws-kms-key-${local.uuid}"
  key_description = var.key_description != null ? var.key_description : "KMS key generated by terraform with open-source-devex/terraform-modules/aws/kms-key"
}

resource "aws_kms_key" "default" {
  description              = local.key_description
  deletion_window_in_days  = var.deletion_window_in_days
  enable_key_rotation      = var.enable_key_rotation
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec

  policy = join("", data.aws_iam_policy_document.final.*.json)

  tags = merge(var.tags, {
    Name = local.key_name
  })
}

resource "aws_kms_alias" "default" {
  name          = "alias/${local.key_name}"
  target_key_id = aws_kms_key.default.key_id
}

data "aws_iam_policy_document" "final" {
  source_policy_documents = compact([
    data.aws_iam_policy_document.key_usage_account.json,
    data.aws_iam_policy_document.key_management_account.json,
    data.aws_iam_policy_document.policy_statements.json,
    var.key_policy_json,
  ])
}

data "aws_iam_policy_document" "key_usage_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [local.account_arn]
    }

    effect = "Allow"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:TagResource",
      "kms:UntagResource",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "key_management_account" {
  # Allow account to manage access to CMK via IAM policies
  # https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html#key-policy-default-allow-root-enable-iam
  dynamic "statement" {
    for_each = var.allow_account_to_manage_key ? [1] : []

    content {
      principals {
        type        = "AWS"
        identifiers = [local.account_arn]
      }
      effect    = "Allow"
      actions   = ["kms:*"]
      resources = ["*"]
    }
  }
}

data "aws_iam_policy_document" "policy_statements" {
  dynamic "statement" {
    for_each = var.key_policy

    content {
      dynamic "principals" {
        for_each = statement.value.principals

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources != null ? statement.value.resources : ["*"]

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []

        content {
          test     = condition.value.test
          variable = condition.value.variable

          values = condition.value.values
        }
      }
    }
  }
}

resource "random_uuid" "name" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
