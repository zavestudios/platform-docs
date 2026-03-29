# ZaveStudios — Execution Environments v0.1

This document defines where platform operators execute commands and which tools are available in each environment.

## Purpose

Platform operations require different tools and access patterns. Without clear documentation, operators must:
- Guess which environment to use
- Install tools ad-hoc
- Work around missing capabilities
- Create inconsistent patterns

This document eliminates ambiguity by declaring:
1. What execution environments exist
2. What tools are available in each
3. Decision matrix: "For operation X, use environment Y"
4. Examples for common operations

---

## Design Principles

### 1. Minimal Workstation

Per `DEVELOPER_EXPERIENCE.md`, workstations must remain "clean and unencumbered."

**Workstation Philosophy:**
- Docker + docker compose only
- No language runtimes, no kubectl, no cloud CLIs
- All work happens in containers
- Exceptions require documented rationale

### 2. Bastion for Cluster Operations

Operations requiring direct cluster access use the bastion host.

**Bastion Philosophy:**
- kubectl, flux, helm for cluster management
- psql for database operations
- No docker/docker compose (bastion is not for development)
- SSH access controlled

### 3. CI/CD for Automation

Repeatable operations belong in GitHub Actions workflows.

**CI/CD Philosophy:**
- Terraform plan/apply
- Database provisioning
- Contract validation
- Image builds
- GitOps PR creation

### 4. Kubernetes Pods for Runtime Operations

Some operations run as Kubernetes Jobs or via pod exec.

**Pod Philosophy:**
- Vault operations (exec into vault pod)
- Break-glass cluster access
- Debugging running workloads

---

## Environment Matrix

| Environment | Primary Use Case | Tools Available | Access Method | Typical Operators |
|-------------|------------------|-----------------|---------------|-------------------|
| **Workstation** | Local development, testing, debugging | docker, docker compose, git, standard unix tools | Local machine | All developers |
| **Bastion Host** | Cluster operations, database access | kubectl, psql, flux, helm | SSH | Platform operators |
| **GitHub Actions** | Automation, CI/CD, infrastructure provisioning | Terraform, psql (installable), docker, git | Workflow dispatch or PR trigger | Automated + platform operators |
| **Kubernetes Pods** | Runtime operations, vault access | Varies by pod (vault CLI in vault pod) | kubectl exec | Platform operators (break-glass) |
| **Docker Compose (in repos)** | Per-repo tooling, isolated environments | Defined per repository via Dockerfile | docker compose run | Developers + operators |

---

## Environment 1: Workstation

### Purpose
Local development, testing, and debugging of workloads.

### Tools Available
- **Required:** docker, docker compose, git
- **Standard unix tools:** bash, curl, openssl, ssh, jq, etc.
- **Explicitly NOT installed:** kubectl, vault CLI, helm, terraform, language runtimes, cloud CLIs

### Rationale
Per `DEVELOPER_EXPERIENCE.md`, workstations must be minimal to:
- Reduce setup friction
- Eliminate platform-specific configuration
- Force containerized workflows
- Prevent "works on my machine" issues

### Access Pattern
```bash
# All work happens via docker compose
cd /path/to/workload-repo
docker compose up

# Run commands in containers, not on host
docker compose exec app pytest
docker compose exec db psql -U postgres
```

### When to Use
- ✅ Developing workload code locally
- ✅ Running workload tests
- ✅ Debugging workload issues
- ✅ Building container images
- ❌ Cluster operations (use bastion)
- ❌ Database provisioning (use GitHub Actions)
- ❌ Vault operations (use bastion or K8s pod)

### Example Operations
```bash
# Start local development environment
cd ~/Dev/panchito
docker compose up

# Run tests
docker compose exec app pytest

# Access local database
docker compose exec db psql -U postgres -d panchito_dev

# Build container image
docker compose build
```

---

## Environment 2: Bastion Host

### Purpose
Cluster operations, database administration, operational tasks requiring kubectl or psql.

### Tools Available
- kubectl
- psql (PostgreSQL client)
- flux (FluxCD CLI)
- helm
- **NOT available:** docker, docker compose

### Access Pattern
```bash
# SSH to bastion
ssh bastion.internal

# Or via kubectl port-forward (if bastion is a pod)
kubectl port-forward -n bastion bastion-0 2222:22
ssh -p 2222 localhost
```

### When to Use
- ✅ kubectl operations (get pods, logs, describe, etc.)
- ✅ flux operations (reconcile, check, etc.)
- ✅ psql database access (read-only queries, schema inspection)
- ✅ helm operations (list releases, get values, etc.)
- ❌ Database provisioning (use GitHub Actions for automation)
- ❌ Terraform operations (use GitHub Actions)
- ❌ Local development (use workstation)

### Example Operations

**Requires bastion access:**

```bash
# Check cluster status
kubectl get nodes
kubectl get pods -A

# View workload logs
kubectl logs -n mia deploy/mia-app

# Flux reconciliation
flux reconcile source git flux-system
flux get kustomizations

# Database inspection (read-only)
psql -h pg-01.internal -U postgres -d db_panchito -c '\dt app.*'

# Helm release inspection
helm list -A
helm get values -n monitoring monitoring-monitoring-kube-prometheus
```

---

## Environment 3: GitHub Actions (CI/CD)

### Purpose
Automated operations, infrastructure provisioning, database bootstrapping, CI/CD pipelines.

### Tools Available
- **Pre-installed:** docker, git, curl, jq, bash
- **Installable:** terraform (via `hashicorp/setup-terraform`), psql (via `apt-get install postgresql-client`), any other apt packages
- **Access to:** GitHub secrets, Vault (via auth), Kubernetes (via kubeconfig secret)

### Access Pattern
Operations triggered via:
- Push to branch (automatic)
- Pull request (automatic)
- `workflow_dispatch` (manual trigger)
- `workflow_call` (reusable workflows)

### When to Use
- ✅ Terraform plan/apply
- ✅ Database provisioning (`provision_tenant.sh` execution)
- ✅ Container image builds
- ✅ Contract validation
- ✅ GitOps PR creation
- ✅ Automated deployments
- ❌ Interactive debugging (use workstation or bastion)
- ❌ Ad-hoc queries (use bastion)

### Available Workflows

#### Platform Pipelines (Shared, Reusable)
Located in `/Users/xavierlopez/Dev/platform-pipelines/.github/workflows/`

**Terraform Workflows:**
- `terraform-plan.yml` - Run terraform plan, comment on PR
- `terraform-apply.yml` - Run terraform apply (auto-approve)

**Database Workflows:**
- `db-bootstrap-psql.yml` - Run SQL scripts via psql client

**Container Workflows:**
- `container-build.yml` - Build multi-platform container images
- `container-promote.yml` - Promote images between registries

**Application Workflows:**
- `python-test.yml` - Run Python tests via pytest
- `rails-test.yml`, `rails-lint.yml` - Rails testing
- `hugo-build.yml`, `hugo-deploy.yml` - Static site builds
- `jekyll-deploy.yml`, `jekyll-validate-front-matter.yml` - Jekyll workflows

**Security Workflows:**
- `security-scan.yml` - Container vulnerability scanning

### Example: Terraform Workflow Usage

**Repository:** `/Users/xavierlopez/Dev/gitops/terraform/postgresql/`

**.github/workflows/provision-keycloak-db.yml:**
```yaml
name: Provision KeyCloak Database

on:
  workflow_dispatch:  # Manual trigger
  push:
    paths:
      - 'terraform/postgresql/**'
    branches:
      - main

jobs:
  terraform:
    uses: zavestudios/platform-pipelines/.github/workflows/terraform-apply.yml@main
    with:
      tf_working_dir: terraform/postgresql
      terraform_version: '1.7.0'
    secrets:
      TF_VARS: |
        {
          "pg_host": "${{ secrets.POSTGRES_HOST }}",
          "pg_port": 5432,
          "pg_admin_user": "postgres",
          "pg_admin_password": "${{ secrets.POSTGRES_ADMIN_PASSWORD }}",
          "pg_sslmode": "require"
        }
```

### Example: Database Provisioning Workflow

**Repository:** `/Users/xavierlopez/Dev/pg/`

**.github/workflows/provision-tenant.yml:**
```yaml
name: Provision Tenant Database

on:
  workflow_dispatch:
    inputs:
      tenant_key:
        description: 'Tenant key (e.g., keycloak, panchito)'
        required: true
      database_name:
        description: 'Database name (e.g., db_keycloak)'
        required: true
      app_role_name:
        description: 'Application role (e.g., keycloak_app)'
        required: true

jobs:
  provision:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install psql
        run: |
          sudo apt-get update
          sudo apt-get install -y postgresql-client

      - name: Generate app password
        id: gen_password
        run: |
          APP_PASSWORD=$(openssl rand -base64 32)
          echo "::add-mask::$APP_PASSWORD"
          echo "app_password=$APP_PASSWORD" >> $GITHUB_OUTPUT

      - name: Run provision_tenant.sh
        env:
          PGHOST: ${{ secrets.POSTGRES_HOST }}
          PGPORT: ${{ secrets.POSTGRES_PORT || '5432' }}
          PGUSER: ${{ secrets.POSTGRES_ADMIN_USER }}
          PGPASSWORD: ${{ secrets.POSTGRES_ADMIN_PASSWORD }}
          TENANT_KEY: ${{ inputs.tenant_key }}
          DB_NAME: ${{ inputs.database_name }}
          APP_ROLE: ${{ inputs.app_role_name }}
          APP_PASSWORD: ${{ steps.gen_password.outputs.app_password }}
        run: |
          ./scripts/provision_tenant.sh \
            --admin-host "$PGHOST" \
            --admin-port "$PGPORT" \
            --admin-user "$PGUSER" \
            --admin-password "$PGPASSWORD" \
            --tenant-key "$TENANT_KEY" \
            --database-name "$DB_NAME" \
            --app-role "$APP_ROLE" \
            --app-password "$APP_PASSWORD"

      - name: Save credentials to Vault (future)
        run: |
          echo "TODO: Write credentials to Vault at tenants/$TENANT_KEY/db"
          echo "APP_PASSWORD: ${{ steps.gen_password.outputs.app_password }}"
```

---

## Environment 4: Kubernetes Pods

### Purpose
Runtime operations that must execute inside the cluster (vault access, break-glass operations, workload debugging).

### Pods with Tools

#### Vault Pod
- **Namespace:** `vault`
- **Pod:** `vault-0` (or similar)
- **Tools:** vault CLI
- **Use case:** Vault operations (kv get, kv put, policy management)

#### Workload Pods
- **Namespace:** Varies (workload-specific)
- **Tools:** Varies per workload Dockerfile
- **Use case:** Debugging running workload

### Access Pattern
```bash
# Exec into vault pod
kubectl exec -n vault vault-0 -it -- sh

# Inside vault pod
vault status
vault kv get secret/platform/storage/pg/admin
```

### When to Use
- ✅ Vault secret operations
- ✅ Debugging running workloads (kubectl exec)
- ✅ Break-glass cluster operations
- ❌ Routine operations (use bastion or GitHub Actions)
- ❌ Database provisioning (use GitHub Actions)

### Example Operations

**Requires cluster access:**

```bash
# Vault operations
kubectl exec -n vault vault-0 -- vault kv get secret/platform/storage/pg/admin

# Debug running workload
kubectl exec -n mia deploy/mia-app -it -- bash
# Inside container: inspect env, check files, run diagnostics

# Break-glass kubectl operations
kubectl patch deployment mia-app -n mia --type='json' -p='[{"op": "replace", "path": "/spec/replicas", "value":0}]'
```

---

## Environment 5: Docker Compose (in repositories)

### Purpose
Per-repository isolated tooling environments. Used when a repository needs specific tools not available in other environments.

### Pattern
Repositories include `docker-compose.yml` with service definitions for any tools needed.

### Example: pg Repository

**Location:** `/Users/xavierlopez/Dev/pg/docker-compose.yml`

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"

  psql-client:
    image: postgres:16
    entrypoint: ["psql"]
    profiles:
      - tools
    environment:
      PGHOST: postgres
      PGUSER: postgres
      PGPASSWORD: password
```

**Usage:**
```bash
cd ~/Dev/pg

# Run psql client
docker compose --profile tools run --rm psql-client -d postgres -c '\l'

# Run provision script in container (if needed)
docker compose run --rm psql-client bash -c './scripts/provision_tenant.sh ...'
```

### When to Use
- ✅ Repository-specific tooling
- ✅ Isolated test environments
- ✅ Local development dependencies
- ❌ Cross-repository operations (use GitHub Actions)

---

## Decision Matrix: Which Environment for Which Operation?

| Operation | Environment | Rationale |
|-----------|-------------|-----------|
| **Develop workload code** | Workstation (docker compose) | Per DEVELOPER_EXPERIENCE.md standard |
| **Run workload tests** | Workstation (docker compose) | Local, fast feedback loop |
| **Build container images** | Workstation or GitHub Actions | Local for testing, GHA for publishing |
| **Provision database (one-time)** | GitHub Actions | Automated, repeatable, auditable |
| **Provision database (Terraform)** | GitHub Actions | Infrastructure as Code workflow |
| **Query database (read-only)** | Bastion | psql client available |
| **Get/put Vault secrets** | Kubernetes (vault pod) | vault CLI only in vault pod |
| **kubectl operations** | Bastion | kubectl available |
| **flux operations** | Bastion | flux CLI available |
| **Terraform plan** | GitHub Actions | Automated on PR |
| **Terraform apply** | GitHub Actions | Automated on merge |
| **Debug running workload** | Kubernetes (workload pod) | kubectl exec into running container |
| **Contract validation** | GitHub Actions | CI/CD pipeline |
| **Create GitOps PR** | GitHub Actions | Automation workflow |
| **Repository-specific tools** | Docker Compose (in repo) | Isolated, version-controlled |

---

## Common Operation Examples

### Operation: Provision New Tenant Database

**❌ Wrong Environment (Bastion):**
```bash
# Bastion has psql but this is manual, not repeatable
ssh bastion.internal
./provision_tenant.sh --admin-host pg-01.internal ...
# Problem: No audit trail, not in Git, hard to reproduce
```

**✅ Right Environment (GitHub Actions):**
```yaml
# .github/workflows/provision-database.yml
# Triggered via workflow_dispatch
# Audit trail in workflow run logs
# Secrets managed via GitHub Secrets
# Reproducible and automatable
```

**Execution:**
```bash
# From workstation
gh workflow run provision-tenant.yml \
  -f tenant_key=keycloak \
  -f database_name=db_keycloak \
  -f app_role_name=keycloak_app
```

---

### Operation: Check Workload Logs

**❌ Wrong Environment (Workstation):**
```bash
# No kubectl on workstation
kubectl logs -n mia deploy/mia-app
# Error: kubectl: command not found
```

**✅ Right Environment (Bastion):**
```bash
ssh bastion.internal
kubectl logs -n mia deploy/mia-app
```

---

### Operation: Get Database Password from Vault

**❌ Wrong Environment (Bastion):**
```bash
# Bastion doesn't have vault CLI
vault kv get secret/platform/storage/pg/admin
# Error: vault: command not found
```

**✅ Right Environment (Kubernetes vault pod):**
```bash
kubectl exec -n vault vault-0 -- vault kv get -field=password secret/platform/storage/pg/admin
```

---

### Operation: Run Terraform Plan

**❌ Wrong Environment (Bastion):**
```bash
# Bastion doesn't have terraform
terraform plan
# Error: terraform: command not found
```

**✅ Right Environment (GitHub Actions):**
```yaml
# .github/workflows/terraform.yml calls platform-pipelines terraform-plan workflow
# Runs on PR, comments plan output
```

---

## Formation Phase: Manual Workarounds

During Formation, some operations may require workarounds when tooling is not yet automated.

### Acceptable Temporary Patterns

**Manual database provisioning from bastion:**
```bash
# Until GitHub Actions workflow exists
ssh bastion.internal
# Transfer provision_tenant.sh to bastion
scp ~/Dev/pg/scripts/provision_tenant.sh bastion.internal:/tmp/
# Run manually
./provision_tenant.sh --admin-host pg-01.internal ...
```

**Manual Terraform from workstation via docker:**
```bash
# Use terraform docker image if no GitHub Actions workflow exists yet
docker run --rm -v $(pwd):/workspace -w /workspace hashicorp/terraform:latest init
docker run --rm -v $(pwd):/workspace -w /workspace hashicorp/terraform:latest plan
```

**These workarounds must be:**
- Documented as temporary
- Tracked as technical debt
- Replaced with proper automation

---

## Roadmap: Execution Environment Improvements

### Short Term (Formation Phase)
1. ✅ Document all environments (this document)
2. ⏳ Create GitHub Actions workflow for database provisioning
3. ⏳ Create GitHub Actions workflow for Terraform operations
4. ⏳ Document bastion access procedures

### Medium Term (Post-Formation)
1. Add vault CLI to bastion (reduce kubectl exec dependency)
2. Create "toolbox" pod in Kubernetes (consolidated operational tools)
3. Standardize docker compose tooling pattern across repos
4. CI/CD enforcement: block operations in wrong environments

### Long Term
1. Remove manual bastion operations (full GitOps automation)
2. Self-service platform operations (developers trigger workflows)
3. Observability: track which environments are used for which operations
4. Automated environment validation (check tool versions, access)

---

## Enforcement

### Formation Phase (Manual)
- Pull request reviews check operation/environment alignment
- Reference this document in review comments
- Escalate violations to platform team

### Target State (Automated)
- CI checks reject kubectl commands in workstation repos
- Bastion audit logs track command usage
- GitHub Actions required for infrastructure changes
- Policy enforcement via Kyverno or OPA

---

## Strategic Role

Execution environments are architectural boundaries.

Without clear documentation:
- Operators waste time finding the right place to run commands
- Operations become ad-hoc and unrepeatable
- Audit trails are incomplete
- Security boundaries are unclear

With clear documentation:
- Every operation has a defined environment
- Automation is prioritized over manual operations
- Audit trails are complete
- Security boundaries are explicit

This document converts platform operations from:

**Ad-hoc execution**
(operators guess where to run commands)

to

**Governed execution**
(operations have defined environments and automation paths)

---

## Related Documentation

- **DEVELOPER_EXPERIENCE.md** — Workstation minimalism principle
- **OPERATING_MODEL.md** — Formation phase automation priorities
- **PR_WORKFLOW.md** — All changes via Git and PR review
- **CONTROL_PLANE_MODEL.md** — GitOps as state authority
