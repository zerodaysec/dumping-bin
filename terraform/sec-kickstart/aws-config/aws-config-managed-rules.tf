locals {
  policy_templates_path = var.custom_policy_templates_path != "" ? var.custom_policy_templates_path : "${path.module}/files/templates"

  iam_user_password_policy_vars = {
    required_uppercase          = var.rule_iam_password_required_uppercase
    required_lowercase          = var.rule_iam_password_required_lowercase
    required_symbols            = var.rule_iam_password_required_symbols
    required_numbers            = var.rule_iam_password_required_numbers
    min_length                  = var.rule_iam_password_min_length
    number_of_passwords_tracked = var.rule_iam_password_number_of_passwords_tracked
    check_password_expires      = var.rule_iam_password_check_expires
    max_age_in_days             = var.rule_iam_password_max_age_in_days
  }
}

###############################################################
# IAM
###############################################################
resource "aws_config_config_rule" "iam_user_password_compliance" {
  count = var.enabled && var.check_iam_user_passwords ? 1 : 0

  name        = "iam-user-password-compliance-${local.resource_name_suffix}"
  description = "Check compliance to IAM password policy"

  input_parameters = templatefile("${local.policy_templates_path}/iam-user-password-policy.json.tpl", local.iam_user_password_policy_vars)

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  maximum_execution_frequency = var.config_max_execution_frequency

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_config_rule" "iam_users_no_direct_policies" {
  count = var.enabled && var.check_iam_users_no_direct_policy ? 1 : 0

  name        = "iam-user-no-policies-${local.resource_name_suffix}"
  description = "Check that IAM users do not have policies directly attached"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_NO_POLICIES_CHECK"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_config_rule" "iam_groups_have_users" {
  count = var.enabled && var.check_iam_groups_have_users ? 1 : 0

  name        = "iam-groups-have-users-${local.resource_name_suffix}"
  description = "Check that IAM groups have users"

  source {
    owner             = "AWS"
    source_identifier = "IAM_GROUP_HAS_USERS_CHECK"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.default]
}

###############################################################
# CloudTrail
###############################################################
resource "aws_config_config_rule" "cloudtrail_is_enabled" {
  count = var.enabled && var.check_cloudtrail_is_enabled ? 1 : 0

  name        = "cloudtrail-is-enabled-${local.resource_name_suffix}"
  description = "Check that CloudTrail is enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  maximum_execution_frequency = var.config_max_execution_frequency

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_config_rule" "cloudtrail_multi_region_is_enabled" {
  count = var.enabled && var.check_cloudtrail_is_multi_region_enabled ? 1 : 0

  name        = "cloudtrail-is-multi-region-enabled-${local.resource_name_suffix}"
  description = "Check that CloudTrail is tracking all regions"

  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }

  maximum_execution_frequency = var.config_max_execution_frequency

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_config_rule" "cloudtrail_encryption_is_enabled" {
  count = var.enabled && var.check_cloudtrail_is_encryption_enabled ? 1 : 0

  name        = "cloudtrail-encryption-enabled-${local.resource_name_suffix}"
  description = "Checks CloudTrail is configured with KMS encryption enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENCRYPTION_ENABLED"
  }

  maximum_execution_frequency = var.config_max_execution_frequency

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_config_rule" "cloudtrail_log_validation_is_enabled" {
  count = var.enabled && var.check_cloudtrail_is_log_validation_enabled ? 1 : 0

  name        = "cloudtrail-log-validation-enabled-${local.resource_name_suffix}"
  description = "Checks CloudTrail is configured with log validation enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED"
  }

  maximum_execution_frequency = var.config_max_execution_frequency

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.default]
}

###############################################################
# EC2 and VPC
###############################################################
resource "aws_config_config_rule" "ec2_instances_deployed_to_vpcs" {
  count = var.enabled && var.check_ec2_instances_deployed_to_vpcs ? 1 : 0

  name        = "ec2-instances-deployed-to-vpcs-${local.resource_name_suffix}"
  description = "Check that all EC2 instances are deployed to a VPC"

  source {
    owner             = "AWS"
    source_identifier = "INSTANCES_IN_VPC"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_config_rule" "ec2_volumes_in_use" {
  count = var.enabled && var.check_ec2_volumes_in_use ? 1 : 0

  name        = "ec2-volumes-in-use-${local.resource_name_suffix}"
  description = "Checks that EBS volumes are in use by an EC2 instance"

  source {
    owner             = "AWS"
    source_identifier = "EC2_VOLUME_INUSE_CHECK"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.default]
}

###############################################################
# EC2 and VPC
###############################################################
resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  count = var.enabled && var.check_s3_bucket_public_read_prohibited ? 1 : 0

  name        = "s3-bucket-public-read-prohibited-${local.resource_name_suffix}"
  description = "Check that S3 buckets do not allow public read access"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_config_rule" "s3_bucket_public_write_prohibited" {
  count = var.enabled && var.check_s3_bucket_public_write_prohibited ? 1 : 0

  name        = "s3-bucket-public-write-prohibited-${local.resource_name_suffix}"
  description = "Check that S3 buckets do not allow public write access"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_config_rule" "s3_bucket_ssl_request_only" {
  count = var.enabled && var.check_s3_bucket_ssl_request_only ? 1 : 0

  name        = "s3-bucket-ssl-request-only-${local.resource_name_suffix}"
  description = "Check that S3 buckets do not allow unencrypted (non SSL) requests"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
  }

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_config_rule" "s3_bucket_encryption_enabled" {
  count = var.enabled && var.check_s3_bucket_is_encryption_enabled ? 1 : 0

  name        = "s3-bucket-encryption-enabled-${local.resource_name_suffix}"
  description = "Check that S3 buckets have server side encryption enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.default]
}
