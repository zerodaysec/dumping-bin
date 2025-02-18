terraform {
  backend "remote" {
    organization = "open-source-devex"
    workspaces {
      name = "terraform-modules-ecr-repository-simple"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "ecr" {
  source = ".."

  project     = "open-source-devex"
  environment = "test"

  name                 = "my-ecr"
  image_tag_mutability = "IMMUTABLE"

  ecr_lifecycle_policy = <<EOD
{
  "rules": [
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
EOD

  read_only_access_accounts = [data.aws_caller_identity.current.account_id]
  read_only_access_services = ["cloudtrail.amazonaws.com"]

  full_access_accounts = [data.aws_caller_identity.current.account_id]
  full_access_services = ["codebuild.amazonaws.com"]
}

output "registries" {
  value = module.ecr.registry
}

data "aws_caller_identity" "current" {}
