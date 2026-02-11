# Terraform Caller Repository

Enterprise Terraform infrastructure with GitHub Actions CI/CD using reusable workflows.

## 🏗️ Project Structure

```
mbb-tf-caller1/
├── .github/workflows/
│   └── terraform-ci.yml          # CI workflow (calls reusable workflow)
├── env/
│   ├── dev/                      # Dev environment
│   │   ├── backend.tf           # Azure backend with OIDC
│   │   ├── provider.tf          # Azure provider config
│   │   ├── main.tf              # Infrastructure (Storage)
│   │   ├── variables.tf         # Variable definitions
│   │   ├── outputs.tf           # Output definitions
│   │   └── terraform.tfvars     # Dev configuration
│   ├── stage/                    # Staging environment (future)
│   └── prod/                     # Production environment (future)
├── modules/
│   └── storage/                  # Reusable storage module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── docs/
    ├── GITHUB-ACTIONS-SETUP.md  # Complete setup guide
    ├── QUICKSTART.md            # 5-minute quickstart
    └── WORKFLOW-REFERENCE.md    # Workflow documentation
```

## 🚀 Quick Start

### Prerequisites
- Azure subscription
- GitHub repository
- Azure CLI installed

### Setup (5 minutes)

1. **Configure Azure OIDC**:
   ```bash
   cd docs
   # Follow steps in QUICKSTART.md
   ```

2. **Add GitHub Secrets**:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`

3. **Test the pipeline**:
   ```bash
   git checkout -b test/ci
   echo "# test" >> env/dev/terraform.tfvars
   git add . && git commit -m "test: CI pipeline"
   git push origin test/ci
   ```

4. **Create PR** and watch the magic happen! ✨

## 📦 What's Deployed

### Dev Environment

- **Azure Storage Account** with:
  - Blob containers (data, logs, backups)
  - Storage queues (tasks, notifications, events)
  - Storage tables (metrics, audit, sessions)
  - Security: HTTPS-only, TLS 1.2, soft delete enabled

### Features

✅ **Azure OIDC Authentication** - No credentials in code  
✅ **Security Scanning** - Checkov + Trivy  
✅ **Terraform Validation** - Format + syntax checks  
✅ **PR Comments** - Automatic plan output  
✅ **Signed Artifacts** - Build provenance attestation  

## 🔄 CI/CD Pipeline

### CI Pipeline (Automated)

Triggers on:
- Push to `main` or `develop`
- Pull requests
- Manual dispatch

Pipeline steps:
1. ✅ Format check (`terraform fmt`)
2. ✅ Syntax validation (`terraform validate`)
3. 🛡️ Security scanning (Checkov, Trivy)
4. 📋 Generate Terraform plan
5. 💬 Comment plan on PR
6. 📦 Upload signed artifacts

**Duration**: ~4 minutes

### Workflow Architecture

```
┌─────────────────────────────────────────────────┐
│  mbb-tf-caller1/.github/workflows/           │
│  terraform-ci.yml (Caller)                      │
│                                                 │
│  Triggers: push, PR, manual                     │
│  Determines: environment to deploy              │
└──────────────────┴──────────────────────────────┘
                   │ calls
                   ▼
┌─────────────────────────────────────────────────┐
│  mbb-tf-workflows/.github/workflows/│
│  reusable-terraform-ci.yml (Reusable)          │
│                                                 │
│  Jobs:                                          │
│  1. terraform-validate (15 min)                 │
│  2. security-scans (30 min)                     │
│  3. terraform-plan (45 min)                     │
└─────────────────────────────────────────────────┘
```

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [QUICKSTART.md](docs/QUICKSTART.md) | Get started in 5 minutes |
| [GITHUB-ACTIONS-SETUP.md](docs/GITHUB-ACTIONS-SETUP.md) | Complete setup guide with Azure OIDC |
| [WORKFLOW-REFERENCE.md](docs/WORKFLOW-REFERENCE.md) | Workflow inputs, outputs, and reference |

## 🛠️ Local Development

### Initialize Terraform

```bash
cd env/dev

# Login to Azure
az login

# Initialize Terraform
terraform init

# Validate
terraform fmt -check
terraform validate

# Plan
terraform plan -var-file=terraform.tfvars

# Apply (if needed)
terraform apply -var-file=terraform.tfvars
```

### Pre-commit Checks

```bash
# Format code
terraform fmt -recursive

# Validate
terraform validate

# Security scan
checkov -d env/dev
```

## 🔐 Security

### Authentication

- **Azure**: OIDC federated credentials (no secrets!)
- **Terraform Backend**: Azure AD authentication
- **GitHub**: Built-in GITHUB_TOKEN

### Scanning

- **Checkov**: 500+ security policies
- **Trivy**: Comprehensive IaC scanner
- **SARIF**: Results uploaded to GitHub Security tab

### Artifact Signing

All Terraform plans are cryptographically signed with:
- SLSA Level 3 build provenance
- GitHub attestations
- Verifiable with `gh attestation verify`

## 🏢 Environment Strategy

| Environment | Branch | Auto-Deploy | Approval Required |
|-------------|--------|-------------|-------------------|
| **dev** | `develop` | ❌ CI only | No |
| **stage** | `main` | ❌ Future | No |
| **prod** | `main` | ❌ Future | Yes |

## 🔧 Customization

### Add New Environment

1. Create directory: `env/stage/`
2. Copy files from `env/dev/`
3. Update `terraform.tfvars`
4. Update workflow triggers

### Add New Module

1. Create directory: `modules/<module-name>/`
2. Add `main.tf`, `variables.tf`, `outputs.tf`
3. Call from `env/<env>/main.tf`

## 🐛 Troubleshooting

### OIDC Authentication Failed

```bash
# Verify federated credentials
az ad app federated-credential list --id <APP_ID>

# Check subject format
# Should be: repo:ORG/REPO:ref:refs/heads/BRANCH
```

### Permission Denied

```bash
# Verify service principal permissions
az role assignment list --assignee <APP_ID>

# Check backend storage permissions
az role assignment list \
  --scope "/subscriptions/<SUB_ID>/resourceGroups/<RG>/providers/Microsoft.Storage/storageAccounts/<STORAGE>"
```

### Plan Fails

```bash
# Check backend config
cat env/dev/backend.tf

# Verify storage account exists
az storage account show -n <STORAGE_ACCOUNT> -g <RESOURCE_GROUP>
```

## 📊 Monitoring

- **GitHub Actions**: All workflow runs
- **Security Tab**: Security scan results
- **Artifacts**: Terraform plans (30-day retention)
- **Azure**: Activity logs for all changes

## 🚦 Next Steps

- [ ] Set up CD pipeline for auto-deployment
- [ ] Add environment protection rules
- [ ] Configure approval gates
- [ ] Add cost estimation
- [ ] Set up drift detection
- [ ] Add prod environment
- [ ] Configure Terraform Cloud/Enterprise

## 🤝 Contributing

1. Create feature branch
2. Make changes
3. Run local validation
4. Push and create PR
5. Review CI results
6. Merge after approval

## 📝 License

[Your License Here]

## 👥 Team

Platform Engineering Team - ProjectAAA
