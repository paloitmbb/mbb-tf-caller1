# ============================================================================
# Global Variables
# ============================================================================

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
  default     = "stage"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# Storage Module Variables
# ============================================================================

variable "storage_resource_group_name" {
  description = "Resource group name for storage resources"
  type        = string
}

variable "storage_create_resource_group" {
  description = "Whether to create a new resource group for storage"
  type        = bool
  default     = true
}

variable "storage_account_name" {
  description = "Base name for storage account (will be suffixed with random string)"
  type        = string
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "storage_account_kind" {
  description = "Storage account kind"
  type        = string
  default     = "StorageV2"
}

variable "storage_access_tier" {
  description = "Access tier for blob storage"
  type        = string
  default     = "Hot"
}

variable "storage_enable_https_traffic_only" {
  description = "Enable HTTPS traffic only"
  type        = bool
  default     = true
}

variable "storage_min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS1_2"
}

variable "storage_allow_nested_items_to_be_public" {
  description = "Allow public access to blob containers"
  type        = bool
  default     = false
}

variable "storage_shared_access_key_enabled" {
  description = "Enable shared access key authentication"
  type        = bool
  default     = true
}

variable "storage_public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "storage_network_rules_enabled" {
  description = "Enable network rules"
  type        = bool
  default     = false
}

variable "storage_network_default_action" {
  description = "Default action for network rules"
  type        = string
  default     = "Deny"
}

variable "storage_network_bypass" {
  description = "Bypass network rules for Azure services"
  type        = list(string)
  default     = ["AzureServices"]
}

variable "storage_network_ip_rules" {
  description = "List of public IP or IP ranges in CIDR format"
  type        = list(string)
  default     = []
}

variable "storage_network_subnet_ids" {
  description = "List of virtual network subnet IDs for storage account network rules"
  type        = list(string)
  default     = []
}

variable "storage_enable_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = false
}

variable "storage_enable_soft_delete" {
  description = "Enable soft delete for blobs"
  type        = bool
  default     = true
}

variable "storage_soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted blobs"
  type        = number
  default     = 7
}

variable "storage_enable_container_soft_delete" {
  description = "Enable soft delete for containers"
  type        = bool
  default     = true
}

variable "storage_container_soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted containers"
  type        = number
  default     = 7
}

variable "storage_enable_static_website" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}

variable "storage_static_website_index_document" {
  description = "Index document for static website"
  type        = string
  default     = "index.html"
}

variable "storage_static_website_error_document" {
  description = "Error document for static website"
  type        = string
  default     = "404.html"
}

variable "storage_containers" {
  description = "List of storage containers to create"
  type = list(object({
    name        = string
    access_type = string
  }))
  default = []
}

variable "storage_queues" {
  description = "List of storage queues to create"
  type        = list(string)
  default     = []
}

variable "storage_tables" {
  description = "List of storage tables to create"
  type        = list(string)
  default     = []
}
