output "iam_password_check_policy" {
  value = join("", aws_config_config_rule.iam_user_password_compliance[*].input_parameters)
}
