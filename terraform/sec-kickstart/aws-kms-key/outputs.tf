output "key_arn" {
  value = aws_kms_key.default.arn
}

output "key_id" {
  value = aws_kms_key.default.key_id
}

output "key_alias_name" {
  value = aws_kms_alias.default.name
}

output "key_alias_arn" {
  value = aws_kms_alias.default.arn
}
