locals {
  setup_read_only_access   = (length(var.read_only_access_accounts) + length(var.read_only_access_services) + length(var.read_only_access_users) + length(var.read_only_access_roles)) > 0
  setup_full_access_access = (length(var.full_access_accounts) + length(var.full_access_services) + length(var.full_access_users) + length(var.full_access_roles)) > 0

  iam_read_only_policy   = join("", data.aws_iam_policy_document.read_only.*.json)
  iam_full_access_policy = join("", data.aws_iam_policy_document.full_access.*.json)
}

# The use of this data source is crashing the aws provider (version 4 and above),
# hence it's commented out until the provider is fixed.
# See: https://github.com/hashicorp/terraform-provider-aws/issues/24366
#data "aws_iam_policy_document" "final" {
#  source_policy_documents = coalesce([local.iam_read_only_policy, local.iam_full_access_policy])
#}

data "aws_iam_policy_document" "read_only" {
  count = local.setup_read_only_access ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = concat(
        var.read_only_access_users,
        var.read_only_access_roles,
        [for account in var.read_only_access_accounts : "arn:aws:iam::${account}:root"]
      )
    }

    principals {
      type = "Service"

      identifiers = var.read_only_access_services
    }

    actions = [
      "ecr:Get*",
      "ecr:Describe*",
      "ecr:List*",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
    ]
  }
}

data "aws_iam_policy_document" "full_access" {
  count = local.setup_full_access_access ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = concat(
        var.full_access_users,
        var.full_access_roles,
        [for account in var.full_access_accounts : "arn:aws:iam::${account}:root"]
      )
    }

    principals {
      type = "Service"

      identifiers = var.full_access_services
    }

    actions = [
      "ecr:*",
    ]
  }
}
