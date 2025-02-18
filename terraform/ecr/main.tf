#tfsec:ignore:aws-ecr-repository-customer-key
resource "aws_ecr_repository" "ecr" {
  name = var.name
  #tfsec:ignore:aws-ecr-enforce-immutable-repository
  image_tag_mutability = var.image_tag_mutability
  tags                 = var.tags

  image_scanning_configuration {
    scan_on_push = var.scan_image_on_push
  }

  dynamic "encryption_configuration" {
    for_each = var.kms_cmk_arn != null ? [1] : []
    content {
      encryption_type = "KMS"
      kms_key         = var.kms_cmk_arn
    }
  }
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.ecr.name
  policy     = var.ecr_lifecycle_policy
}

resource "aws_ecr_repository_policy" "ecr" {
  count = local.setup_read_only_access || local.setup_full_access_access ? 1 : 0

  repository = aws_ecr_repository.ecr.name
  # The use of the data source is crashing the aws provider (see iam.tf for more details)
  #  policy     = data.aws_iam_policy_document.final.json
  policy = local.setup_read_only_access ? local.iam_read_only_policy : local.iam_full_access_policy
}
