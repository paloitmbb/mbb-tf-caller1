# Reusable Workflow Reference

## terraform-ci.yml (Caller Workflow)

### Triggers

```yaml
on:
  push:
    branches: [main, develop]
    paths: ['env/**', 'modules/**', '.github/workflows/terraform-ci.yml']
  
  pull_request:
    branches: [main, develop]
    paths: ['env/**', 'modules/**']
  
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [dev, stage, prod]
```

### Jobs

1. **prepare** - Determines which environment to validate
2. **terraform-ci** - Calls reusable workflow
3. **summary** - Displays results

## reusable-terraform-ci.yml (Reusable Workflow)

### Inputs

| Input | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `terraform-version` | string | No | `1.7.0` | Terraform version |
| `working-directory` | string | No | `.` | Directory with Terraform code |
| `environment` | string | **Yes** | - | Environment name (dev/stage/prod) |
| `terraform-var-file` | string | No | `""` | Variable file name |
| `enable-checkov` | boolean | No | `true` | Enable Checkov scanning |
| `enable-trivy` | boolean | No | `true` | Enable Trivy scanning |
| `checkov-severity` | string | No | `HIGH` | Minimum severity (HIGH/MEDIUM/LOW) |
| `runner-os` | string | No | `ubuntu-latest` | GitHub runner OS |
| `timeout-minutes` | number | No | `60` | Maximum execution time |

### Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `AZURE_CLIENT_ID` | No* | Azure App Registration Client ID |
| `AZURE_TENANT_ID` | No* | Azure Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | No* | Azure Subscription ID |

*Required for Azure deployments

### Outputs

| Output | Type | Description |
|--------|------|-------------|
| `plan-artifact-name` | string | Name of uploaded Terraform plan artifact |
| `plan-exitcode` | string | Terraform plan exit code (0=no changes, 2=changes) |
| `security-scan-passed` | boolean | Whether all security scans passed |
| `plan-hash` | string | SHA256 hash of Terraform plan |

### Jobs

#### 1. terraform-validate

**Purpose**: Validate Terraform syntax and formatting

**Steps**:
- Checkout code
- Setup Terraform
- Format check (`terraform fmt -check`)
- Init (`terraform init`)
- Validate (`terraform validate`)

**Duration**: ~15 minutes

#### 2. security-scans

**Purpose**: Security scanning of IaC code

**Steps**:
- Checkout code
- Run Checkov (if enabled)
- Run Trivy (if enabled)
- Upload SARIF results
- Aggregate results

**Duration**: ~30 minutes

**Outputs**: Security scan results in GitHub Security tab

#### 3. terraform-plan

**Purpose**: Generate execution plan

**Steps**:
- Checkout code
- Azure Login (OIDC)
- Setup Terraform
- Init
- Generate plan (`terraform plan -detailed-exitcode`)
- Convert to JSON
- Generate hash
- Create metadata
- Sign with attestation
- Upload artifacts
- Comment on PR

**Duration**: ~45 minutes

**Artifacts**:
- `tfplan` - Binary plan file
- `tfplan.json` - JSON plan
- `plan-metadata.json` - Metadata
- `plan-output.txt` - Human-readable plan

## Usage Example

```yaml
# In mbb-tf-caller1/.github/workflows/terraform-ci.yml
jobs:
  terraform-ci:
    uses: ./.github/workflows/reusable-terraform-ci.yml
    with:
      terraform-version: '1.7.0'
      working-directory: './env/dev'
      environment: 'dev'
      enable-checkov: true
      enable-trivy: true
      checkov-severity: 'HIGH'
      terraform-var-file: 'terraform.tfvars'
    secrets:
      AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Environment Variables

Set automatically by the workflow:

```yaml
env:
  TF_IN_AUTOMATION: 'true'
  TF_INPUT: 'false'
  TF_CLI_ARGS: '-no-color'
```

## Permissions Required

```yaml
permissions:
  contents: read           # Read repository
  security-events: write   # Upload security scans
  id-token: write          # OIDC authentication
  pull-requests: write     # Comment on PRs
  attestations: write      # Sign artifacts
```

## Exit Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | No changes | ✅ Success, skip deployment |
| 1 | Error | ❌ Fail workflow |
| 2 | Changes detected | ✅ Success, proceed to deployment |

## Artifact Naming

Format: `tfplan-{env}-{commit-sha}-{timestamp}`

Example: `tfplan-dev-a1b2c3d-20260204-143022`

## Security Scanning

### Checkov

- 500+ built-in policies
- SARIF output to GitHub Security
- Configurable severity threshold
- Framework: Terraform, CloudFormation, Kubernetes, etc.

### Trivy

- Comprehensive IaC scanner
- Detects misconfigurations
- SARIF output to GitHub Security
- Supports multiple IaC frameworks

## Attestation & Signing

Uses GitHub's native attestation:
- SLSA Level 3 build provenance
- Cryptographically signed artifacts
- Verifiable with `gh attestation verify`

## Best Practices

1. **Always use specific Terraform versions** - Avoid `latest`
2. **Enable all security scans** - Checkov + Trivy
3. **Set appropriate severity** - `HIGH` for prod, `MEDIUM` for dev
4. **Use OIDC** - No long-lived credentials
5. **Review plan before merge** - Check PR comments
6. **Keep state backend secure** - Use Azure AD auth
7. **Validate locally first** - `terraform fmt` and `terraform validate`

## Troubleshooting

### Workflow not triggering
- Check path filters match your changes
- Verify branch names
- Check workflow permissions

### OIDC auth fails
- Verify federated credentials
- Check subject matches repository
- Ensure service principal has permissions

### Security scans fail
- Review findings in Security tab
- Check severity threshold
- Update Terraform code

### Plan fails
- Check backend configuration
- Verify Azure permissions
- Review Terraform syntax

## Next Steps

- [ ] Add CD workflow for auto-deployment
- [ ] Configure environment protection rules
- [ ] Add cost estimation step
- [ ] Set up drift detection
- [ ] Add policy-as-code (OPA)
