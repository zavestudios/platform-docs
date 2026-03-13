# ZaveStudios — POC Graduation Process v0.1

This document defines how POC repositories graduate to contract-governed categories (tenant, platform-service, or infrastructure).

Graduation occurs when a POC proves a concept viable and the decision is made to adopt it for production use.

---

## Graduation Overview

**Graduation Pattern: Migrate + Generate (Clean)**

POCs graduate by:
1. Creating a new contract-governed repository (generated from contract)
2. Migrating POC implementation code into generated structure
3. Archiving POC repository with graduation notice

**Why this pattern:**
- Keeps generators pure (deterministic: contract → output)
- POC stays as design artifact (preserved for reference)
- Graduated repo has standard structure (contract-derived)
- Clean separation: exploration vs. production

---

## When to Graduate

Graduate a POC when:

- ✅ POC recommendation is **"adopt"**
- ✅ POC has proven technical viability
- ✅ Decision made to move to production implementation
- ✅ Target category identified (tenant, platform-service, infrastructure)

Do NOT graduate if:

- ❌ Recommendation is "defer" or "reject" → Archive instead
- ❌ POC incomplete or inconclusive → Keep Active or Archive
- ❌ Uncertainty about production adoption → Defer decision

---

## Graduation Process

### Step 1: Extract Contract from POC

Review POC implementation and determine contract parameters.

**For tenant or portfolio workloads:**

```yaml
# zave.yaml (to be created in new repo)
apiVersion: zave.io/v1
kind: Workload
metadata:
  name: k8s-runtime-security

spec:
  runtime: container  # or static
  exposure: public-http  # or internal-http, none
  delivery: rolling  # only option in Formation v0.1

  build:
    mode: dockerfile  # required in v0.1

  persistence:  # optional
    engine: postgres

  capabilities:  # optional
    - name: metrics
    - name: tracing

  resources:  # optional
    tier: standard
```

**Determine parameters:**
- `metadata.name`: Service identifier (DNS-compatible)
- `spec.runtime`: `container` or `static`
- `spec.exposure`: How service is accessed
- `spec.delivery`: `rolling` (only option in Formation v0.1)
- `spec.persistence`: Database if needed
- `spec.capabilities`: Platform modules to attach

**For platform-service:**
- No contract required (not deployable workload)
- Repository scaffold follows platform-service conventions
- Consumed by other workloads, not deployed independently

---

### Step 2: Generate New Repository

**Formation Phase (Manual):**

Until `zave init` command exists, manually create repository:

1. Create new GitHub repository
2. Add contract file (`zave.yaml`)
3. Add repository scaffold:
   ```
   new-repo/
   ├── zave.yaml
   ├── README.md
   ├── src/
   ├── Dockerfile
   ├── .github/workflows/
   │   └── build.yaml  (calls platform-pipelines)
   └── docker-compose.yml or docker-compose.yaml  (local dev - see DEVELOPER_EXPERIENCE.md)
   ```

4. Bind platform workflows (reference `platform-pipelines` shared workflows)

**Target State (Automated):**

Once generators are implemented:

```bash
zave init tenant k8s-runtime-security --from-contract zave.yaml
```

This command will:
- Create repository with generated structure
- Bind platform workflows
- Register in GitOps
- Produce deployable system

---

### Step 3: Migrate Implementation

Copy POC implementation code into generated repository structure.

**What to migrate:**
- ✅ Source code (`src/`, `app/`, etc.)
- ✅ Tests (`tests/`, `spec/`, etc.)
- ✅ Documentation (`docs/`)
- ✅ Configuration examples (`.env.example`)
- ✅ Dependencies (`requirements.txt`, `package.json`, etc.)

**What NOT to migrate:**
- ❌ POC README (keep for design history)
- ❌ Ad-hoc scripts not needed in production
- ❌ Experimental code paths not adopted

**Adapt code if needed:**
- Update imports/paths for new structure
- Integrate with platform conventions
- Ensure Dockerfile works in new context

---

### Step 4: Preserve Design History

POC README contains valuable design thinking. Preserve it.

**In new repository:**

Create `docs/DESIGN.md`:

```bash
cp gitlab-poc-repo/README.md github-new-repo/docs/DESIGN.md
```

Update new repository's README to link to design history:

```markdown
# k8s-runtime-security

[Standard tenant README content...]

## Design History

This workload originated from a POC evaluation.

See [DESIGN.md](docs/DESIGN.md) for the original architectural evaluation,
trade-off analysis, and recommendation that led to this implementation.

**Original POC:** https://gitlab.com/zavestudios/poc/k8s-runtime-security
```

---

### Step 5: Archive POC Repository

Update POC repository with graduation notice.

**Update POC README:**

Add graduation notice at the top:

```markdown
# k8s-runtime-security

> **🎓 This POC has graduated!**
>
> **Status:** Graduated
> **Graduated To:** tenant
> **New Repository:** https://github.com/zavestudios/k8s-runtime-security
> **Graduation Date:** 2026-06-15
>
> This repository remains as historical record of the design process and architectural evaluation.

---

[Rest of original POC README preserved below...]
```

**Update repository description:**

Change GitLab/GitHub repository description to:

```
(Graduated) POC: Kubernetes Runtime Threat Detection - See github.com/zavestudios/k8s-runtime-security
```

**No deletion:**
- POC repository remains accessible
- All design thinking preserved
- Future reference for similar evaluations

---

### Step 6: Deploy to Platform

Follow platform deployment process for new workload.

**Formation Phase (Manual):**

1. Push new repository to GitHub
2. Create GitOps manifests in `gitops/tenants/[workload]/`
3. Create ArgoCD Application resource
4. Merge to gitops repository
5. Verify deployment

**Target State (Automated):**

Contract merge triggers:
- CI builds image
- Image pushed to registry
- GitOps PR auto-created
- Workload registers automatically

---

## Graduation Checklist

Use this checklist to ensure complete graduation:

- [ ] POC recommendation is explicit: "adopt"
- [ ] Target category identified (tenant, platform-service, etc.)
- [ ] Contract parameters determined
- [ ] New repository created with generated structure
- [ ] Implementation code migrated successfully
- [ ] POC design history preserved in `docs/DESIGN.md`
- [ ] New repository README links to design history
- [ ] POC README updated with graduation notice
- [ ] POC repository description updated
- [ ] New workload deployed successfully (if applicable)
- [ ] POC archived (status updated to "Graduated")

---

## Example Graduation

**Before Graduation:**

```
gitlab.com/zavestudios/poc/k8s-runtime-security
- Status: Active
- Contains: POC code, README with design evaluation
- Not deployed to production cluster
```

**After Graduation:**

```
github.com/zavestudios/k8s-runtime-security
- Contract-governed tenant workload
- Deployed via GitOps
- README links to design history (docs/DESIGN.md)
- Uses platform-pipelines shared workflows

gitlab.com/zavestudios/poc/k8s-runtime-security
- Status: Graduated
- README has graduation notice linking to production repo
- Preserved as design history reference
```

---

## Graduation Variants

### Variant A: Graduate to `tenant`

**When:** POC is a deployable workload (API, service, application)

**Process:** Steps 1-6 above

**Result:** Contract-governed tenant in GitHub, deployed via GitOps

---

### Variant B: Graduate to `platform-service`

**When:** POC is a reusable capability (CI/CD workflows, shared modules)

**Process:**
- No contract required (platform-services don't deploy independently)
- Follow platform-service repository conventions
- May provide reusable workflows, libraries, or tools

**Example:** POC evaluating new CI/CD pattern graduates to `platform-pipelines`

---

### Variant C: Graduate to `infrastructure`

**When:** POC is infrastructure tooling (GitOps patterns, cluster config)

**Process:**
- No contract required
- Follow infrastructure repository conventions
- May mutate shared infrastructure state

**Example:** POC for FluxCD setup graduates to `gitops` repository updates

---

## Rollback / Reversal

If graduated workload fails in production:

**Option 1: Fix Forward**
- Debug and fix in production repository
- POC remains archived

**Option 2: Rollback to POC**
- Revert GitOps registration
- Mark new repository as archived
- Update POC status: `Graduated` → `Active`
- Resume POC development

**When to rollback:**
- Fundamental design flaw discovered
- Production requirements differ significantly from POC
- Need to re-evaluate alternatives

---

## Future Automation

**Target state** (post-Formation):

```bash
# Automated graduation command
zave graduate poc k8s-runtime-security --to tenant

# This would:
# 1. Extract contract from POC
# 2. Run zave init with contract
# 3. Smart-migrate code (preserve src/, docs/, tests/)
# 4. Update POC with graduation notice
# 5. Create GitOps PR
```

This tool orchestrates graduation without polluting generators.

Generators stay pure: `contract → artifacts`

Graduation tool is separate migration orchestrator.

---

## Strategic Role

Graduation process ensures:

- **POCs have clear exit path** — Success means production adoption
- **Design thinking preserved** — POC README becomes `docs/DESIGN.md`
- **Generators stay simple** — No need to "wrap around" existing code
- **Clean authority boundaries** — POCs explore, contracts govern production

Graduation converts validated exploration into governed execution.

---

## Related Documentation

- **POC_GOVERNANCE.md** — POC governance model
- **POC_LIFECYCLE.md** — POC states including Graduated
- **GENERATOR_MODEL.md** — How generators create contract-governed repos
- **LIFECYCLE_MODEL.md** — Platform workload lifecycle (what graduated repos enter)
- **REPO_TAXONOMY.md** — Repository classification
