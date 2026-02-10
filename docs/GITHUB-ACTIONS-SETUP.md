# GitHub Actions CI Pipeline Setup

This guide explains how to set up the Terraform CI pipeline with GitHub Actions and Azure OIDC authentication.

## 🏗️ Architecture

```
mbb-tf-caller1 (This Repo)
├── .github/workflows/terraform-ci.yml   ← Caller workflow
└── env/dev/                             ← Terraform code

mbb-tf-workflows (Shared Repo)
└── .github/workflows/
    └── reusable-terraform-ci.yml        ← Reusable workflow
```

## 🔐 Azure OIDC Setup (No Secrets Required!)

### Step 1: Create Azure App Registration

```bash
# Login to Azure
az login

# Create app registration
az ad app create \
  --display-name "GitHub-Actions-Terraform-OIDC-2" \
  --sign-in-audience AzureADMyOrg

# Get the Application (Client) ID
APP_ID=$(az ad app list --display-name "GitHub-Actions-Terraform-OIDC-2" --query "[0].appId" -o tsv)
echo "AZURE_CLIENT_ID: $APP_ID"

# Create service principal
az ad sp create --id $APP_ID

# Get Tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "AZURE_TENANT_ID: $TENANT_ID"

# Get Subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
```

### Step 2: Configure Federated Credentials

```bash
# Set your GitHub organization and repository
GITHUB_ORG="paloitmbb"
GITHUB_REPO="mbb-tf-caller1"

# Get the Object ID of the service principal
OBJECT_ID=$(az ad sp list --display-name "GitHub-Actions-Terraform-OIDC-2" --query "[0].id" -o tsv)

# Create federated credential for main branch
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "GitHubActionsMain",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'"$GITHUB_ORG"'/'"$GITHUB_REPO"':ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Create federated credential for develop branch
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "GitHubActionsDevelop",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'"$GITHUB_ORG"'/'"$GITHUB_REPO"':ref:refs/main/develop",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Create federated credential for pull requests
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "GitHubActionsPR",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'"$GITHUB_ORG"'/'"$GITHUB_REPO"':pull_request",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### Step 3: Create Terraform State Storage

```bash
# Create resource group for Terraform state
az group create \
  --name rg-terraform-state \
  --location eastus

# Create storage account
az storage account create \
  --name ghsttfstatedev001 \
  --resource-group rg-terraform-state \
  --location eastus \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

# Create container for state files
az storage container create \
  --name tfstate \
  --account-name ghsttfstatedev001 \
  --auth-mode login
```

### Step 4: Assign Azure Permissions

```bash
# Assign Contributor role for infrastructure deployment
az role assignment create \
  --assignee $APP_ID \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# For backend state storage, assign Storage Blob Data Contributor
# Replace with your actual state storage account resource group and name
TFSTATE_RG="rg-terraform-state"
TFSTATE_STORAGE="ghsttfstatedev001"

az role assignment create \
  --assignee $APP_ID \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$TFSTATE_RG/providers/Microsoft.Storage/storageAccounts/$TFSTATE_STORAGE"
```



## 🔧 GitHub Repository Setup

### Step 5: Add GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions → New repository secret

Add these three secrets:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `AZURE_CLIENT_ID` | `<APP_ID from Step 1>` | Application (Client) ID |
| `AZURE_TENANT_ID` | `<TENANT_ID from Step 1>` | Azure Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | `<SUBSCRIPTION_ID from Step 1>` | Azure Subscription ID |

**Note**: These are not sensitive secrets, just identifiers. No passwords or keys needed!

### Step 6: Update Backend Configuration

Update [`env/dev/backend.tf`](env/dev/backend.tf) with your storage account details:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstatedev001"  # ← Your storage account
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
    use_azuread_auth     = true  # ← OIDC authentication
  }
}
```

## 🚀 Testing the Pipeline

### Step 7: Test the Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b test/ci-pipeline
   ```

2. **Make a change** to trigger the pipeline:
   ```bash
   # Make a small change to terraform.tfvars
   echo "" >> env/dev/terraform.tfvars
   git add .
   git commit -m "test: trigger CI pipeline"
   git push origin test/ci-pipeline
   ```

3. **Create a Pull Request**:
   - Go to GitHub and create a PR from your branch to `develop`
   - The CI pipeline should automatically run
   - Check the PR comment for the Terraform plan output

### Step 8: Verify the Pipeline

The pipeline will:

1. ✅ **Validate** Terraform code (format, syntax)
2. 🛡️ **Security Scan** with Checkov and Trivy
3. 📋 **Generate Plan** using Azure OIDC auth
4. 💬 **Comment on PR** with plan details
5. 📦 **Upload Artifacts** (plan files)

Check:
- Actions tab → Your workflow run
- PR comments for Terraform plan
- Security tab → Code scanning alerts

## 📁 Workflow Files

### Caller Workflow
Location: [`.github/workflows/terraform-ci.yml`](.github/workflows/terraform-ci.yml)

Triggers:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual dispatch

### Reusable Workflow
Location: `mbb-tf-workflows/.github/workflows/terraform-ci.yml`

Features:
- Terraform validation
- Security scanning (Checkov, Trivy)
- Plan generation
- Artifact attestation
- PR comments

## 🔍 Monitoring

### GitHub Actions
- **Actions Tab**: View all workflow runs
- **Security Tab**: View security scan results
- **Pull Requests**: See plan comments

### Azure
- **Activity Log**: View all resource changes
- **Storage Account**: Verify state file updates

## 🐛 Troubleshooting

### OIDC Authentication Failed
```
Error: AADSTS700016: Application with identifier 'XXX' was not found
```
**Solution**: Verify federated credentials match your repository name exactly

### Permission Denied on State Storage
```
Error: storage: service returned error: StatusCode=403
```
**Solution**: Ensure "Storage Blob Data Contributor" role is assigned

### Plan Fails with "Backend initialization required"
```
Error: Backend initialization required
```
**Solution**: Update backend.tf with correct storage account details

## 📚 Next Steps

After CI is working:
1. ✅ Set up CD pipeline (auto-deploy to dev)
2. ✅ Add environment protection rules
3. ✅ Configure approval gates for prod
4. ✅ Set up drift detection
5. ✅ Add cost estimation

## 🔗 References

- [Azure OIDC with GitHub Actions](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure)
- [Terraform Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
