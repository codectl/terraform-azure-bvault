output "data_protection_backup_vault" {
  description = "contains all exported attributes of the data protection backup vault"
  value       = azurerm_data_protection_backup_vault.this
}

output "policy_blob_storage" {
  description = "contains all exported attributes of the data protection backup policy blob storage"
  value       = azurerm_data_protection_backup_policy_blob_storage.this
}

output "instance_blob_storage" {
  description = "contains all exported attributes of the data protection backup instance blob storage"
  value       = azurerm_data_protection_backup_instance_blob_storage.this
}

output "policy_disks" {
  description = "contains all exported attributes of the data protection backup policy disk"
  value       = azurerm_data_protection_backup_policy_disk.this
}

output "instance_disks" {
  description = "contains all exported attributes of the data protection backup instance disk"
  value       = azurerm_data_protection_backup_instance_disk.this
}

output "policy_postgresql_flexible_servers" {
  description = "contains all exported attributes of the data protection backup policy postgresql flexible server"
  value       = azurerm_data_protection_backup_policy_postgresql_flexible_server.this
}

output "instance_postgresql_flexible_servers" {
  description = "contains all exported attributes of the data protection backup instance postgresql flexible server"
  value       = azurerm_data_protection_backup_instance_postgresql_flexible_server.this
}
