# Quick Start: GitHub Actions CI Pipeline

## ⚡ 5-Minute Setup

### 1. Azure Setup (One-time)

```bash
# Create App Registration
az ad app create --display-name "GitHub-Actions-Terraform-OIDC"
APP_ID=$(az ad app list --display-name "GitHub-Actions-Terraform-OIDC" --query "[0].appId" -o tsv)
az ad sp create --id $APP_ID

# Get IDs (save these!)
echo "AZURE_CLIENT_ID: $APP_ID"
echo "AZURE_TENANT_ID: $(az account show --query tenantId -o tsv)"
echo "AZURE_SUBSCRIPTION_ID: $(az account show --query id -o tsv)"

# Configure federated credentials (replace YOUR_ORG/YOUR_REPO)
az ad app federated-credential create --id $APP_ID --parameters '{
  "name": "GitHubMain",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:YOUR_ORG/YOUR_REPO:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'

# Assign permissions
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az role assignment create --assignee $APP_ID --role "Contributor" --scope "/subscriptions/$SUBSCRIPTION_ID"
```

### 2. GitHub Setup

**Add Secrets** (Settings → Secrets → Actions):
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

### 3. Test

```bash
git checkout -b test/ci
echo "# test" >> env/dev/terraform.tfvars
git add . && git commit -m "test: CI"
git push origin test/ci
```

Create PR → Check Actions tab ✅

## 📋 Workflow Overview

```yaml
# .github/workflows/terraform-ci.yml
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  terraform-ci:
    uses: ./.github/workflows/reusable-terraform-ci.yml
    secrets: inherit
```

## ✅ What Gets Checked

| Step | Tool | Time |
|------|------|------|
| Format | `terraform fmt` | 10s |
| Validate | `terraform validate` | 30s |
| Security | Checkov + Trivy | 2min |
| Plan | `terraform plan` | 1min |
| Total | | ~4min |

## 🎯 Key Features

✅ **No credentials in code** - OIDC authentication  
✅ **Security scanning** - Checkov & Trivy  
✅ **PR comments** - Automatic plan output  
✅ **Signed artifacts** - Build provenance  
✅ **Fail fast** - Early validation  

## 🔗 Files Created

```
mbb-tf-caller1/
├── .github/workflows/
│   └── terraform-ci.yml          ← Workflow trigger
├── env/dev/
│   ├── backend.tf               ← Azure backend (OIDC)
│   ├── provider.tf              ← Azure provider
│   ├── main.tf                  ← Storage module
│   ├── variables.tf             ← Variables
│   ├── outputs.tf               ← Outputs
│   └── terraform.tfvars         ← Config values
└── docs/
    └── GITHUB-ACTIONS-SETUP.md  ← Full guide
```

## 📖 Full Documentation

See [GITHUB-ACTIONS-SETUP.md](GITHUB-ACTIONS-SETUP.md) for complete setup instructions.
