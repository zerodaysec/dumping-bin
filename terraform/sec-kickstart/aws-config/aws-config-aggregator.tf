locals {
  enable_aggregation              = var.enabled && var.enable_aggregation && !var.enable_organization
  enable_organization_aggregation = var.enabled && var.enable_aggregation && var.enable_organization

  aggregator_name = var.aggregator_name != "" ? var.aggregator_name : "aws-config-aggregator-${local.resource_name_suffix}"
}

resource "aws_config_configuration_aggregator" "account" {
  count = local.enable_aggregation ? 1 : 0

  name = local.aggregator_name

  account_aggregation_source {
    account_ids = var.aggregated_accounts
    all_regions = true
  }

  tags = var.tags
}

resource "aws_config_configuration_aggregator" "organization" {
  count = local.enable_organization_aggregation ? 1 : 0

  name = local.aggregator_name

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.organization_aggregator.arn
  }

  tags = var.tags
}

resource "aws_iam_role" "organization_aggregator" {
  name = local.aggregator_name

  assume_role_policy = data.aws_iam_policy_document.organization_aggregator_assume_role.json
}

data "aws_iam_policy_document" "organization_aggregator_assume_role" {

  statement {
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "organization" {
  role       = aws_iam_role.organization_aggregator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}
