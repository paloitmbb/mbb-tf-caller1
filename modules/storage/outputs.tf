output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "storage_account_secondary_access_key" {
  description = "The secondary access key for the storage account"
  value       = azurerm_storage_account.main.secondary_access_key
  sensitive   = true
}

output "storage_account_primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "storage_account_secondary_connection_string" {
  description = "The secondary connection string for the storage account"
  value       = azurerm_storage_account.main.secondary_connection_string
  sensitive   = true
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint for the storage account"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "storage_account_primary_queue_endpoint" {
  description = "The primary queue endpoint for the storage account"
  value       = azurerm_storage_account.main.primary_queue_endpoint
}

output "storage_account_primary_table_endpoint" {
  description = "The primary table endpoint for the storage account"
  value       = azurerm_storage_account.main.primary_table_endpoint
}

output "storage_account_primary_file_endpoint" {
  description = "The primary file endpoint for the storage account"
  value       = azurerm_storage_account.main.primary_file_endpoint
}

output "container_ids" {
  description = "Map of container names to their IDs"
  value       = { for k, v in azurerm_storage_container.containers : k => v.id }
}

output "queue_ids" {
  description = "Map of queue names to their IDs"
  value       = { for k, v in azurerm_storage_queue.queues : k => v.id }
}

output "table_ids" {
  description = "Map of table names to their IDs"
  value       = { for k, v in azurerm_storage_table.tables : k => v.id }
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = var.create_resource_group ? azurerm_resource_group.storage[0].name : var.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = var.location
}

output "static_website_url" {
  description = "The URL of the static website (if enabled)"
  value       = var.enable_static_website ? azurerm_storage_account.main.primary_web_endpoint : null
}
