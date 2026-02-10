terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = { # ✅ ADD THIS
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Random string for unique storage account name
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Resource Group (if creating new one)
resource "azurerm_resource_group" "storage" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location

  tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Module    = "storage"
    }
  )
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "${var.storage_account_name}${random_string.storage_suffix.result}"
  resource_group_name      = var.create_resource_group ? azurerm_resource_group.storage[0].name : var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier

  # Security settings
  enable_https_traffic_only       = var.enable_https_traffic_only
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled

  # Network rules
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "network_rules" {
    for_each = var.network_rules_enabled ? [1] : []
    content {
      default_action             = var.network_default_action
      bypass                     = var.network_bypass
      ip_rules                   = var.network_ip_rules
      virtual_network_subnet_ids = var.network_subnet_ids
    }
  }

  # Blob properties
  dynamic "blob_properties" {
    for_each = var.enable_versioning || var.enable_soft_delete ? [1] : []
    content {
      versioning_enabled = var.enable_versioning

      dynamic "delete_retention_policy" {
        for_each = var.enable_soft_delete ? [1] : []
        content {
          days = var.soft_delete_retention_days
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = var.enable_container_soft_delete ? [1] : []
        content {
          days = var.container_soft_delete_retention_days
        }
      }
    }
  }

  # Static website (optional)
  dynamic "static_website" {
    for_each = var.enable_static_website ? [1] : []
    content {
      index_document     = var.static_website_index_document
      error_404_document = var.static_website_error_document
    }
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      tags["CreatedDate"]
    ]
  }
}

# Storage Containers
resource "azurerm_storage_container" "containers" {
  for_each              = { for c in var.containers : c.name => c }
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = each.value.access_type
}

# Storage Queues
resource "azurerm_storage_queue" "queues" {
  for_each             = toset(var.queues)
  name                 = each.value
  storage_account_name = azurerm_storage_account.main.name
}

# Storage Tables
resource "azurerm_storage_table" "tables" {
  for_each             = toset(var.tables)
  name                 = each.value
  storage_account_name = azurerm_storage_account.main.name
}
