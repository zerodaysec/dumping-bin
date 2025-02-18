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
  description = "The region where the trail bucket or the log group is created, will default to the region of the provider when lefts empty."
  default     = ""
}

variable "is_guardduty_master" {
  description = "Whether the account is a master account"
  type        = bool
  default     = false
}

variable "is_guardduty_member" {
  description = "Whether the account is a member account"
  type        = bool
  default     = false
}

variable "enable_detector" {
  description = "Whether to enable monitoring and feedback reporting"
  type        = bool
  default     = true
}

variable "detector_frequency" {
  description = "Specifies the frequency of notifications sent for subsequent finding occurrences. If the detector is a GuardDuty member account, the value is determined by the GuardDuty master account and cannot be modified, otherwise defaults to SIX_HOURS. For standalone and GuardDuty master accounts, it must be configured in Terraform to enable drift detection. Valid values for standalone and master accounts: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
  type        = string
  default     = "SIX_HOURS"
}

variable "activate_ipset" {
  description = "Whether to have GuardDuty start using the uploaded IPSet"
  type        = bool
  default     = true
}

variable "ipset_format" {
  description = "The format of the file that contains the IPSet"
  type        = string
  default     = "TXT"
}

variable "ipset_iplist" {
  description = "IPSet list of trusted IP addresses"
  type        = list(string)
  default     = []
}

variable "activate_threatintelset" {
  description = "Whether to have GuardDuty start using the uploaded ThreatIntelSet"
  type        = bool
  default     = true
}

variable "threatintelset_format" {
  description = "The format of the file that contains the ThreatIntelSet"
  type        = string
  default     = "TXT"
}

variable "threatintelset_iplist" {
  type        = list(string)
  description = "ThreatIntelSet list of known malicious IP addresses"
  default     = []
}

variable "master_account_id" {
  type        = string
  description = "Account ID for Guard Duty Master. Required if is_guardduty_member"
  default     = ""
}

variable "member_list" {
  description = "The list of member accounts to be added. Each member list need to have values of account_id, member_email and invite boolean"

  type = list(object({
    account_id   = string
    member_email = string
    invite       = bool
  }))

  default = []
}

variable "create_s3_bucket" {
  description = "Whether to create an S3 bucket to hold lists of IPs"
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket where lists of IPs will be stored. Leave empty to assign default name"
  type        = string
  default     = ""
}

variable "s3_bucket_force_destroy" {
  description = "Allow terraform to destroy the bucket created by this module when it wants to remove or recrete it"
  type        = bool
  default     = false
}

variable "s3_bucket_block_public_access" {
  description = "Whether to place a block on public access to the created S3 bucket"
  type        = bool
  default     = true
}

variable "enable_organization" {
  description = "Whether to control guardduty from the aws organization."
  type        = bool
  default     = true
}

variable "auto_enable_organization_members" {
  description = "Indicates the auto-enablement configuration of GuardDuty for the member accounts in the organization."
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ALL", "NEW", "NONE"], var.auto_enable_organization_members)
    error_message = "Only valid options are ALL, NEW, NONE"
  }
}
