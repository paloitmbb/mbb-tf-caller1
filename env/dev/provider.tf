terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }

    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }

  # Azure AD authentication options (choose one):

  # Option 1: Use OIDC (recommended for GitHub Actions)
  use_oidc = true

  # Option 2: Use Managed Identity (for Azure-hosted runners)
  # use_msi = true

  # Option 3: Use Service Principal with client secret
  # Uses environment variables:
  # - ARM_CLIENT_ID
  # - ARM_CLIENT_SECRET
  # - ARM_TENANT_ID
  # - ARM_SUBSCRIPTION_ID

  # Option 4: Use Azure CLI authentication (local development)
  # Automatically uses `az login` credentials

  skip_provider_registration = false
}

provider "random" {
  # Random provider for generating unique resource names
}
