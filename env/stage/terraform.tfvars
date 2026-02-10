# ============================================================================
# Stage Environment Configuration - Storage Only
# ============================================================================

environment = "stage"
location    = "eastus"

common_tags = {
  Environment = "stage"
  ManagedBy   = "Terraform"
  Project     = "MayBank-CloudDays"
  CostCenter  = "Engineering"
  Owner       = "DevOps Team"
}

# ============================================================================
# Storage Configuration
# ============================================================================

storage_resource_group_name   = "rg-storage-stage"
storage_create_resource_group = true

storage_account_name             = "stagestapp" # Will be suffixed with random string
storage_account_tier             = "Standard"
storage_account_replication_type = "GRS"
storage_account_kind             = "StorageV2"
storage_access_tier              = "Hot"

# Security settings
storage_enable_https_traffic_only       = true
storage_min_tls_version                 = "TLS1_2"
storage_allow_nested_items_to_be_public = false
storage_shared_access_key_enabled       = false
storage_public_network_access_enabled   = false

# Network rules (enabled for stage)
storage_network_rules_enabled  = true
storage_network_default_action = "Deny"
storage_network_bypass         = ["AzureServices"]
storage_network_ip_rules       = []

# Blob properties
storage_enable_versioning                    = true
storage_enable_soft_delete                   = true
storage_soft_delete_retention_days           = 14
storage_enable_container_soft_delete         = true
storage_container_soft_delete_retention_days = 14

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
