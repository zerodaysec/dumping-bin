variable "name" {
  description = "The name for the inspector-kickstarter, used in all related resources"
  type        = string
  default     = "inspector"
}

variable "enable" {
  description = "Whether to enable this module"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags appended to all resources that will take them"
  type        = map(string)
  default     = { vulnerability-assessment = true }
}

variable "aws_region" {
  description = "The AWS region where the Inspector kickstarter should live and check"
  type        = string
}

variable "ecs_network_mode" {
  description = "The network mode for the ECS task"
  type        = string
  default     = "awsvpc"
}

variable "ecs_launch_type" {
  description = "The launch type for the ECS task"
  type        = string
  default     = "FARGATE"
}

variable "assessment_instance_subnet_ids" {
  description = "The subnet IDs that will be used to deploy instances in"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC where the ECS task will be launched"
  type        = string
}


variable "ecs_cluster_id" {
  description = "The ECS cluster ARN that will be used to deploy inspector-kickstarter"
  type        = string
}

variable "inspector_kickstarter_container_image" {
  description = "The container image for the inspector kickstarter"
  type        = string
  default     = "registry.gitlab.com/open-source-devex/containers/inspector-kickstarter"
}

variable "inspector_kickstarter_container_task_cpu" {
  default = 256
  type    = number
}

variable "inspector_kickstarter_container_task_memory" {
  default = 512
  type    = number
}

variable "inspector_kickstarter_container_memory_reservation" {
  default = 64
  type    = number
}

variable "cloudwatch_cron_schedule" {
  description = "The cloudwatch event cron schedule for triggering inspector scans, set to null to disable schedule"
  type        = string
  default     = "cron(0 3 * * ? *)"
}

variable "cloudwatch_log_group" {
  description = "The cloudwatch log group for ECS container logging"
  type        = string
  default     = "/aws/ecs/inspector-kickstarter"
}

variable "create_sns_topic" {
  description = "Whether to create an SNS topic"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "The ARN of an SNS topic to use when `create_sns_topic = false`"
  type        = string
  default     = ""
}
