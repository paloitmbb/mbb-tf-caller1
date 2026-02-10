terraform {
  backend "azurerm" {
    # Azure Storage Account backend using Azure AD authentication (OIDC/RBAC)
    # No access keys required - uses Azure AD credentials

    resource_group_name  = "rg-terraform-state"
    storage_account_name = "ghsttfstateprod001"
    container_name       = "tfstate"
    key                  = "prod/terraform.tfstate"

    # Use Azure AD authentication instead of access keys
    use_azuread_auth = true

    # Optional: Specify subscription if different from default
    # subscription_id = "00000000-0000-0000-0000-000000000000"

    # Optional: Use OIDC authentication (recommended for CI/CD)
    use_oidc = true

    # Optional: Use Managed Identity (for Azure-hosted runners)
    # use_msi = true
  }
}

# Required RBAC permissions for the identity accessing the backend:
# - Storage Blob Data Contributor (or Owner) on the storage account or container
# - Reader on the resource group containing the storage account
#
# For OIDC in GitHub Actions, set these secrets:
# - AZURE_CLIENT_ID
# - AZURE_TENANT_ID
# - AZURE_SUBSCRIPTION_ID
#
# For Service Principal:
# - ARM_CLIENT_ID
# - ARM_CLIENT_SECRET (if not using OIDC)
# - ARM_TENANT_ID
# - ARM_SUBSCRIPTION_ID
