variable "project" {
  type    = string
  default = "prj"
}

variable "environment" {
  type    = string
  default = "env"
}

variable "tags" {
  description = "Tags to be added to resources that support it"
  type        = map(string)
  default     = {}
}

variable "enabled" {
  description = "Whether to create any resource within this module"
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "The region where the config bucket is created, will default to the region of the provider when lefts empty."
  type        = string
  default     = ""
}

variable "recorder_name" {
  description = "The name for the AWS Config recorder, leave empty to use the default name"
  type        = string
  default     = ""
}

variable "create_recorder" {
  description = "Whether to create the recorder and delivery channel resources (which have to be unique per account)"
  type        = bool
  default     = true
}

variable "recording_enabled" {
  description = "Set to false to stop recording"
  type        = bool
  default     = true
}

variable "delivery_channel_name" {
  description = "The name for the AWS Config delivery channel, leave empty to use the default name"
  type        = string
  default     = ""
}

variable "config_delivery_frequency" {
  description = "The frequency with which AWS Config delivers configuration snapshots."
  type        = string
  default     = "Six_Hours"
}

variable "config_max_execution_frequency" {
  description = "The maximum frequency with which AWS Config runs evaluations for a rule, if the rule is triggered at a periodic frequency. Valid values: One_Hour, Three_Hours, Six_Hours, Twelve_Hours, or TwentyFour_Hours."
  type        = string
  default     = "TwentyFour_Hours"
}

variable "create_bucket" {
  description = "Set to true to create the bucket"
  type        = bool
  default     = false
}

variable "bucket_name" {
  description = "The name of the S3 bucket where to store logs, leve empty to give it the default name"
  type        = string
  default     = ""
}

variable "bucket_object_prefix" {
  description = "The prefix to use for the log objects stored in the S3 bucket"
  type        = string
  default     = ""
}

variable "bucket_force_destroy" {
  description = "Force terraform to destroy the config bucket created by this module when it wants to remove or recrete it"
  type        = bool
  default     = false
}

variable "bucket_block_public_access" {
  description = "Whether to place a block on public access to the S3 bucket"
  type        = bool
  default     = true
}

variable "iam_service_role_name" {
  description = "The name for the IAM role assumed by AWs Config, leave empty to use the default name"
  type        = string
  default     = ""
}

variable "aws_config_kms_arns" {
  description = "The arns of (cross account) kms keys to trust."
  type        = list(string)
  default     = []
}

###############################################################
# Managed rule toggle switches
###############################################################
variable "enable_aggregation" {
  description = "Set to true to setup aggregation of inventory and compliancy across multiple acounts"
  type        = bool
  default     = false
}

variable "enable_organization" {
  description = "Set to true to setup aggregation accross an organization"
  type        = bool
  default     = false
}

variable "aggregated_accounts" {
  description = "List of the account IDs from where the aggregator should pull data"
  type        = list(string)
  default     = []
}

variable "aggregator_name" {
  description = "The name for the AWS Config aggregator, leave empty to use the default name"
  type        = string
  default     = ""
}

variable "custom_policy_templates_path" {
  description = "Path to a directotry containing policy templates, leave empty to use default templates bundled with module"
  type        = string
  default     = ""
}

###############################################################
# Managed rule toggle switches
###############################################################
variable "check_iam_user_passwords" {
  description = "Set to false to disable the check for IAM user password compliance"
  type        = bool
  default     = true
}

variable "check_iam_users_no_direct_policy" {
  description = "Set to false to disable the check for IAM user having no policies directly attached"
  type        = bool
  default     = true
}

variable "check_iam_groups_have_users" {
  description = "Set to false to disable the check for IAM groups having users"
  type        = bool
  default     = true
}

variable "check_cloudtrail_is_enabled" {
  description = "Set to false to disable the check for CloudTrail enabled"
  type        = bool
  default     = true
}

variable "check_cloudtrail_is_multi_region_enabled" {
  description = "Set to false to disable the check for CloudTrail multi-region enabled"
  type        = bool
  default     = true
}

variable "check_cloudtrail_is_encryption_enabled" {
  description = "Set to false to disable the check for CloudTrail encryption enabled"
  type        = bool
  default     = true
}

variable "check_cloudtrail_is_log_validation_enabled" {
  description = "Set to false to disable the check for CloudTrail log validation enabled"
  type        = bool
  default     = true
}

variable "check_ec2_instances_deployed_to_vpcs" {
  description = "Set to false to disable the check for EC2 deployed to VPCs"
  type        = bool
  default     = true
}

variable "check_ec2_volumes_in_use" {
  description = "Set to false to disable the check for EC2 volumes in use"
  type        = bool
  default     = true
}

variable "check_s3_bucket_public_read_prohibited" {
  description = "Set to false to disable the check for S3 buckets not allowing public read access"
  type        = bool
  default     = true
}

variable "check_s3_bucket_public_write_prohibited" {
  description = "Set to false to disable the check for S3 buckets not allowing public write access"
  type        = bool
  default     = true
}

variable "check_s3_bucket_ssl_request_only" {
  description = "Set to false to disable the check for S3 buckets not allowing unencrypted (non SSL) requests"
  type        = bool
  default     = true
}

variable "check_s3_bucket_is_encryption_enabled" {
  description = "Set to false to disable the check for S3 buckets having server side encryption enabled"
  type        = bool
  default     = true
}

###############################################################
# Managed rule configuration
###############################################################
variable "rule_iam_password_required_uppercase" {
  type    = bool
  default = true
}

variable "rule_iam_password_required_lowercase" {
  type    = bool
  default = true
}

variable "rule_iam_password_required_symbols" {
  type    = bool
  default = true
}

variable "rule_iam_password_required_numbers" {
  type    = bool
  default = true
}

variable "rule_iam_password_min_length" {
  type    = number
  default = 60
}

variable "rule_iam_password_number_of_passwords_tracked" {
  type    = number
  default = 10
}

variable "rule_iam_password_check_expires" {
  type    = bool
  default = false
}

variable "rule_iam_password_max_age_in_days" {
  type    = number
  default = -1
}
