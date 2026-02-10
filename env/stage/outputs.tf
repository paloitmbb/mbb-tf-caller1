# ============================================================================
# Storage Module Outputs
# ============================================================================

output "storage_resource_group_name" {
  description = "Storage resource group name"
  value       = module.storage.resource_group_name
}

output "storage_account_id" {
  description = "Storage account ID"
  value       = module.storage.storage_account_id
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.storage.storage_account_name
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = module.storage.storage_account_primary_blob_endpoint
}

output "storage_account_primary_queue_endpoint" {
  description = "Primary queue endpoint"
  value       = module.storage.storage_account_primary_queue_endpoint
}

output "storage_account_primary_table_endpoint" {
  description = "Primary table endpoint"
  value       = module.storage.storage_account_primary_table_endpoint
}

output "storage_container_ids" {
  description = "Map of container names to IDs"
  value       = module.storage.container_ids
}

output "storage_queue_ids" {
  description = "Map of queue names to IDs"
  value       = module.storage.queue_ids
}

output "storage_table_ids" {
  description = "Map of table names to IDs"
  value       = module.storage.table_ids
}

output "static_website_url" {
  description = "Static website URL if enabled"
  value       = module.storage.static_website_url
}

# ============================================================================
# Environment Summary
# ============================================================================

output "environment_summary" {
  description = "Summary of deployed environment"
  value = {
    environment = var.environment
    location    = var.location

    storage = {
      resource_group   = module.storage.resource_group_name
      storage_account  = module.storage.storage_account_name
      containers_count = length(module.storage.container_ids)
      queues_count     = length(module.storage.queue_ids)
      tables_count     = length(module.storage.table_ids)
    }
  }
}
