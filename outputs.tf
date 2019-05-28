output "recovery_password" {
  value     = local.recovery_password
  sensitive = true
}

output "id" {
  value = "${null_resource.adds.id}"
}
