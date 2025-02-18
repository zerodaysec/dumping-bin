variable "project" {
  description = "The name of the project to which the resources belong"
  type        = string
}

variable "environment" {
  description = "The name of the environment to which the resources belong."
  type        = string
}

variable "tags" {
  description = "Tags to be set on all resources."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The name of the repository to be created."
  type        = string
  default     = ""
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE."
  type        = string
  default     = "MUTABLE"
}

variable "scan_image_on_push" {
  description = "Whether to trigger a scan for vulnerabilities when new images are pushed."
  type        = bool
  default     = true
}

variable "ecr_lifecycle_policy" {
  description = "Rules to be added to the ECR lifecycle policy."
  type        = string

  default = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
        "description": "Keep last 10 final releases",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["v"],
          "countType": "imageCountMoreThan",
          "countNumber": 10
        },
        "action": {
          "type": "expire"
        }
    },
    {
      "rulePriority": 2,
      "description": "Keep last 30 release candidates",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["RC"],
        "countType": "imageCountMoreThan",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 3,
      "description": "Expire untagged images older than 15 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 15
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

variable "read_only_access_accounts" {
  description = "AWS accounts IDs that should have read only access to the repository."
  type        = list(string)
  default     = []
}

variable "read_only_access_services" {
  description = "AWS services that should have read only access to the repository."
  type        = list(string)
  default     = []
}


variable "read_only_access_roles" {
  description = "AWS role ARNs that should have read only access to the repository."
  type        = list(string)
  default     = []
}


variable "read_only_access_users" {
  description = "AWS user ARNs that should have read only access to the repository."
  type        = list(string)
  default     = []
}


variable "full_access_accounts" {
  description = "AWS accounts that should have full access to the repository."
  type        = list(string)
  default     = []
}

variable "full_access_services" {
  description = "AWS services that should have full access to the repository."
  type        = list(string)
  default     = []
}

variable "full_access_roles" {
  description = "AWS role ARNs that should have full access to the repository."
  type        = list(string)
  default     = []
}


variable "full_access_users" {
  description = "AWS user ARNs that should have full access to the repository."
  type        = list(string)
  default     = []
}

variable "kms_cmk_arn" {
  description = "The ARN of a KMS CMK to use for encryption at rest in the repository."
  type        = string
  default     = null
}
