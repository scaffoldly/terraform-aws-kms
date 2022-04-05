output "stage" {
  value       = var.stage
  description = "Re-output of var.stage"
}

output "key_id" {
  value = aws_kms_key.key.key_id
}

output "key_alias" {
  value = aws_kms_alias.alias.name
}
