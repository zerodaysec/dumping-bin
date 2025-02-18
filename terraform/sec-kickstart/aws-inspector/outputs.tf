output "sns_topic_inspector_alerts" {
  value = aws_sns_topic.sns_topic_inspector_alerts.*.arn
}

output "cloudwatch_log_group_inspector" {
  value = var.cloudwatch_log_group
}

output "inspector_kickstarter_role_arn" {
  value = join("", aws_iam_role.inspector_kickstarter_role.*.arn)
}

output "inspector_kickstarter_role_id" {
  value = join("", aws_iam_role.inspector_kickstarter_role.*.id)
}
