# ============================================================================
# Dev Environment Configuration - Storage Only
# ============================================================================

environment = "dev"
location    = "eastus"

common_tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
  Project     = "MayBank-CloudDays"
  CostCenter  = "Engineering"
  Owner       = "DevOps Team"
}

# ============================================================================
# Storage Configuration
# ============================================================================

storage_resource_group_name   = "rg-storage-dev"
storage_create_resource_group = true

storage_account_name             = "devstapp01" # Will be suffixed with random string
storage_account_tier             = "Standard"
storage_account_replication_type = "LRS"
storage_account_kind             = "StorageV2"
storage_access_tier              = "Cool"

# Security settings
storage_enable_https_traffic_only       = true
storage_min_tls_version                 = "TLS1_2"
storage_allow_nested_items_to_be_public = false
storage_shared_access_key_enabled       = true
storage_public_network_access_enabled   = true

# Network rules (disabled for dev, enabled for prod)
storage_network_rules_enabled  = false
storage_network_default_action = "Deny"
storage_network_bypass         = ["AzureServices"]
storage_network_ip_rules       = []

# Blob properties
storage_enable_versioning                    = false
storage_enable_soft_delete                   = true
storage_soft_delete_retention_days           = 7
storage_enable_container_soft_delete         = true
storage_container_soft_delete_retention_days = 7

# Static website (disabled)
storage_enable_static_website         = false
storage_static_website_index_document = "index.html"
storage_static_website_error_document = "404.html"

# Create containers, queues, and tables
storage_containers = [
  {
    name        = "data"
    access_type = "private"
  },
  {
    name        = "logs"
    access_type = "private"
  },
  {
    name        = "backups"
    access_type = "private"
  }
]

storage_queues = ["tasks", "notifications", "events"]
storage_tables = ["metrics", "audit", "sessions"]

######
