# ============================================================================
# Dev Environment - Storage Module Only
# ============================================================================

module "storage" {
  source = "../../modules/storage"

  environment         = var.environment
  resource_group_name = var.storage_resource_group_name
  location            = var.location

  create_resource_group = var.storage_create_resource_group
  storage_account_name  = var.storage_account_name

  # Storage configuration
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = var.storage_account_kind
  access_tier              = var.storage_access_tier

  # Security settings
  enable_https_traffic_only       = var.storage_enable_https_traffic_only
  min_tls_version                 = var.storage_min_tls_version
  allow_nested_items_to_be_public = var.storage_allow_nested_items_to_be_public
  shared_access_key_enabled       = var.storage_shared_access_key_enabled
  public_network_access_enabled   = var.storage_public_network_access_enabled

  # Network rules
  network_rules_enabled  = var.storage_network_rules_enabled
  network_default_action = var.storage_network_default_action
  network_bypass         = var.storage_network_bypass
  network_ip_rules       = var.storage_network_ip_rules
  network_subnet_ids     = var.storage_network_subnet_ids

  # Blob properties
  enable_versioning                    = var.storage_enable_versioning
  enable_soft_delete                   = var.storage_enable_soft_delete
  soft_delete_retention_days           = var.storage_soft_delete_retention_days
  enable_container_soft_delete         = var.storage_enable_container_soft_delete
  container_soft_delete_retention_days = var.storage_container_soft_delete_retention_days

  # Static website
  enable_static_website         = var.storage_enable_static_website
  static_website_index_document = var.storage_static_website_index_document
  static_website_error_document = var.storage_static_website_error_document

  # Resources to create
  containers = var.storage_containers
  queues     = var.storage_queues
  tables     = var.storage_tables

  tags = var.common_tags
}
# Test PR security pipeline - Updated workflow comment format
#PR Trigger 3

#PULL REQUEST DEMO
#PULL REQUEST DEMO1
#PULL REQUEST DEMO2
