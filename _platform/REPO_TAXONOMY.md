# ZaveStudios — Repository Taxonomy

## Purpose

This document defines the canonical classification of all repositories in the ZaveStudios organization.

It exists to eliminate ambiguity for:

- Humans navigating the system
- Agents performing cross-repo work
- Change-scope analysis
- Architectural governance

Every repository must belong to exactly one **category**.

---

## Repository Categories

### `control-plane`
Authoritative architectural doctrine, operating model, and governance contracts.

These define how the system works.
They do not deploy workloads or mutate infrastructure.

---

### `infrastructure`
Repositories that define or mutate shared runtime substrate.

These may provision clusters, manage GitOps state, or configure shared infrastructure resources.

---

### `platform-service`
Reusable capabilities consumed by tenants.

These may include:
- CI/CD workflows
- Supply-chain primitives (image factories)
- Shared workload-level capabilities (e.g., DB provisioning modules)

They do not represent standalone business workloads.

---

### `tenant`
Deployable workloads governed by the platform contract.

These consume shared workflows and inherit lifecycle and governance rules automatically.


---

### `portfolio`
External-facing or personal projects outside the platform reference model.

---

## Repository Classification Table

| Repository | Category | deploys_runtime | mutates_shared_infrastructure | provides_reusable_capability | consumes_shared_workflows |
|------------|----------|----------------|-------------------------------|------------------------------|---------------------------|
| `platform-docs` | control-plane | No | No | Yes | No |
| `platform-pipelines` | platform-service | No | No | Yes | No |
| `image-factory` | platform-service | No | No | Yes | Yes |
| `kubernetes-platform-infrastructure` | infrastructure | No | Yes | No | No |
| `ansible` | infrastructure | No | Yes | No | No |
| `gitops` | infrastructure | No | Yes | No | Possibly |
| `bigbang` | infrastructure | No | Yes | No | No |
| `data-pipelines` | tenant | Yes | No | No | Yes |
| `rigoberta` | tenant | Yes | No | No | Yes |
| `panchito` | tenant | Yes | No | No | Yes |
| `thehouseguy` | tenant | Yes | No | No | Yes |
| `oracle` | tenant | Yes | No | No | Yes |
| `mia` | tenant | Yes | No | No | Yes |
| `xavierlopez.me` | portfolio | Yes | No | No | Yes |
| `zavestudios` | portfolio | Yes | No | No | Yes |
| `pg` | platform-service | No | No | Yes | Possibly |

---

## Classification Notes

### Portfolio Repositories

**`zavestudios`**
- Public documentation and marketing site (zavestudios.com)
- Deploys Hugo static site using shared platform workflows
- Does not follow full platform contract model (no zave.yaml)
- Consumes platform-pipelines workflows for deployment
- Classified as `portfolio` (external-facing project, not platform-governed workload)

**`xavierlopez.me`**
- Personal portfolio site (Jekyll)
- Uses platform-pipelines shared workflows for CI/CD
- Does not follow full platform contract model (no zave.yaml)
- Classified as `portfolio` (external-facing project)
- Not subject to full platform lifecycle governance

### Future Tenants

**`mia`**
- OpenClaw AI assistant workload (not yet created)
- Will be hosted in Kubernetes as platform-governed tenant
- Reserved in taxonomy for future deployment

### Portfolio Contract Migration

**Current State (Formation v0.1):**
- Portfolio repositories (`xavierlopez.me`, `zavestudios`) consume shared workflows but do not follow the platform contract model
- Classified as `portfolio` to indicate external-facing projects with partial governance
- Currently lack `zave.yaml` and contract validation

**Target State:**
- Portfolio repositories should be migrated to contract-governed model
- Contract schema already reserves `spec.runtime: static` for static site workloads
- Example target contract:
  ```yaml
  apiVersion: zave.io/v1
  kind: Workload
  metadata:
    name: zavestudios-com
  spec:
    runtime: static
    exposure: public-http
    delivery: rolling
  ```

**Rationale:**
- Formation phase exit criteria: "≥80% of workloads deploy via the contract without repo design decisions"
- If portfolio sites cannot use the contract model, that indicates platform incompleteness, not valid exception
- Proves contract model works for all workload types, not just applications
- Eliminates special-case workflows and governance exceptions

**Classification Decision:**
- Once contract-governed, portfolio repositories may be reclassified as `tenant` (contract-governed workloads)
- Alternatively, may remain `portfolio` with notation "contract-governed portfolio workload"
- Decision to be formalized in future ADR

---

## Governance Rules

1. Repository category is declared authoritatively in `REPO_TAXONOMY`.

2. Each repository README should reflect its declared category for local clarity, but the taxonomy file remains the canonical source of truth.

3. Reclassification of any repository requires an explicit update to `REPO_TAXONOMY` via pull request.

4. Only `infrastructure` repositories may mutate shared infrastructure state.

5. Only `tenant` repositories may deploy runtime workloads.

6. `platform-service` repositories provide reusable capabilities and must not define independent business workloads.

7. `portfolio` repositories are excluded from platform invariants unless explicitly promoted into a governed category.

Ambiguity is architectural debt.  
Classification changes must be deliberate and reviewable.