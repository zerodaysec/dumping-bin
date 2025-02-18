variable "tags" {
  description = "Tags to be added to resources that support it"
  type        = map(string)
  default     = {}
}

variable "key_name" {
  description = "The value set on the Name tag"
  type        = string
  default     = null
}

variable "key_description" {
  description = "The description for the key"
  type        = string
  default     = null
}

variable "key_policy" {
  description = "Statements for the key policy."

  type = list(object({
    principals = list(object({
      type = string, identifiers = list(string)
    }))
    effect    = string
    actions   = list(string)
    resources = optional(list(string))
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))

  default = [
    #    {
    #      principals = [{
    #        type = "AWS", identifiers = ["foo"]
    #      }]
    #      effect     = "Allow"
    #      actions    = ["foo", "bar"]
    #      resources  = ["*"]
    #      condition  = [{
    #        test     = "StringLike"
    #        variable = "kms:EncryptionContext:aws:cloudtrail:arn"
    #        values   = ["arn:aws:cloudtrail:*:ACCOUNT:trail/*"]
    #      }]
    #    }
  ]
}

variable "key_policy_json" {
  description = "Policy JSON for the key."
  type        = string
  default     = ""
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Invalid value for deletion window in days."
  }
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
  default     = true
}

variable "allow_account_to_manage_key" {
  description = "Whether to create a key policy that allows the account to manage access to the key via IAM policies. See AWS docs for more details https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html#key-policy-default-allow-root-enable-iam."
  type        = bool
  default     = false
}

variable "key_usage" {
  description = "The intended use of the key. Valid values: ENCRYPT_DECRYPT, SIGN_VERIFY or GENERATE_VERIFY_MAC"
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "customer_master_key_spec" {
  description = "The type of key material to use for the CMK. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, HMAC_256, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1"
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}
