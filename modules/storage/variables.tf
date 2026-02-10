variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "create_resource_group" {
  description = "Whether to create a new resource group"
  type        = bool
  default     = false
}

variable "storage_account_name" {
  description = "Base name for storage account (will be suffixed with random string)"
  type        = string
  validation {
    condition     = length(var.storage_account_name) <= 16 && can(regex("^[a-z0-9]+$", var.storage_account_name))
    error_message = "Storage account name must be lowercase alphanumeric and max 16 chars (8 chars reserved for random suffix)"
  }
}

variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either Standard or Premium"
  }
}

variable "account_replication_type" {
  description = "Storage account replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Invalid replication type"
  }
}

variable "account_kind" {
  description = "Storage account kind (Storage, StorageV2, BlobStorage, FileStorage, BlockBlobStorage)"
  type        = string
  default     = "StorageV2"
}

variable "access_tier" {
  description = "Access tier for blob storage (Hot or Cool)"
  type        = string
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Access tier must be either Hot or Cool"
  }
}

# Security variables
variable "enable_https_traffic_only" {
  description = "Enable HTTPS traffic only"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimum TLS version (TLS1_0, TLS1_1, TLS1_2)"
  type        = string
  default     = "TLS1_2"
}

variable "allow_nested_items_to_be_public" {
  description = "Allow public access to blob containers"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Enable shared access key authentication"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

# Network rules
variable "network_rules_enabled" {
  description = "Enable network rules"
  type        = bool
  default     = false
}

variable "network_default_action" {
  description = "Default action for network rules (Allow or Deny)"
  type        = string
  default     = "Deny"
}

variable "network_bypass" {
  description = "Bypass network rules for Azure services"
  type        = list(string)
  default     = ["AzureServices"]
}

variable "network_ip_rules" {
  description = "List of public IP or IP ranges in CIDR format"
  type        = list(string)
  default     = []
}

variable "network_subnet_ids" {
  description = "List of virtual network subnet IDs"
  type        = list(string)
  default     = []
}

# Blob properties
variable "enable_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = false
}

variable "enable_soft_delete" {
  description = "Enable soft delete for blobs"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted blobs"
  type        = number
  default     = 7
}

variable "enable_container_soft_delete" {
  description = "Enable soft delete for containers"
  type        = bool
  default     = true
}

variable "container_soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted containers"
  type        = number
  default     = 7
}

# Static website
variable "enable_static_website" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}

variable "static_website_index_document" {
  description = "Index document for static website"
  type        = string
  default     = "index.html"
}

variable "static_website_error_document" {
  description = "Error document for static website"
  type        = string
  default     = "404.html"
}

# Containers, queues, and tables
variable "containers" {
  description = "List of storage containers to create"
  type = list(object({
    name        = string
    access_type = string
  }))
  default = []
}

variable "queues" {
  description = "List of storage queues to create"
  type        = list(string)
  default     = []
}

variable "tables" {
  description = "List of storage tables to create"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
