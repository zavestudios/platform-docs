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
External-facing workloads (marketing sites, portfolios, public docs) that
remain fully governed by platform contracts and lifecycle rules.

Portfolio is a presentation/domain classification, not a governance exemption.

---

### `index`
Repository discovery and navigation surfaces.

These repositories may provide pointers, context, and links for humans and agents.
They are explicitly non-authoritative and must not define governance doctrine,
contract schema, lifecycle semantics, or implementation mechanics.

---

## Repository Classification Table

| Repository | Category | terraform_class (overlay) | deploys_runtime | mutates_shared_infrastructure | provides_reusable_capability | consumes_shared_workflows |
|------------|----------|---------------------------|----------------|-------------------------------|------------------------------|---------------------------|
| `platform-docs` | control-plane | N/A | No | No | Yes | No |
| `platform-pipelines` | platform-service | N/A | No | No | Yes | No |
| `image-factory` | platform-service | N/A | No | No | Yes | Yes |
| `kubernetes-platform-infrastructure` | infrastructure | sandbox | No | Yes | No | No |
| `ansible` | infrastructure | N/A | No | Yes | No | No |
| `gitops` | infrastructure | N/A | No | Yes | No | Possibly |
| `bigbang` | infrastructure | N/A (external mirror) | No | Yes | No | No |
| `data-pipelines` | tenant | N/A | Yes | No | No | Yes |
| `rigoberta` | tenant | N/A | Yes | No | No | Yes |
| `panchito` | tenant | N/A | Yes | No | No | Yes |
| `thehouseguy` | tenant | N/A | Yes | No | No | Yes |
| `oracle` | tenant | N/A | Yes | No | No | Yes |
| `mia` | tenant | N/A | Yes | No | No | Yes |
| `xavierlopez.me` | portfolio | N/A | Yes | No | No | Yes |
| `zavestudios` | portfolio | N/A | Yes | No | No | Yes |
| `pg` | platform-service | N/A | No | No | Yes | Possibly |
| `zavestudios-architecture` | index | N/A | No | No | No | No |

---

## Classification Notes

### Terraform Overlay Classification

Terraform is a secondary classification overlay, not a primary repository category.

Primary category remains authoritative (`control-plane`, `infrastructure`, `platform-service`, `tenant`, `portfolio`, `index`).

For `infrastructure` repositories that are Terraform-managed, use one of:

- `modules` - reusable Terraform modules
- `sandbox` - non-production or experimental stacks
- `production` - production-affecting stacks

Implementation note:

- GitHub repositories are flat within an organization. `IAC/Terraform/*` is represented through naming, topics, teams, and rulesets, not nested repository folders, like Gitlab.

Current assignments:

- `kubernetes-platform-infrastructure` => `terraform_class: sandbox`
- `bigbang` => tracked as `infrastructure` with no Terraform overlay class in this org; consumed as an external GitLab mirror from upstream

### Portfolio Repositories

**`zavestudios`**
- Public documentation and marketing site (zavestudios.com)
- Deploys Hugo static site using shared platform workflows
- Classified as `portfolio` (external-facing workload)
- Must follow the same contract, validation, and lifecycle model as tenant workloads

### Index Repositories

**`zavestudios-architecture`**
- Landing/index repository for GitHub discovery
- Points to canonical documentation and active workload/governance repositories
- Classified as `index` (non-authoritative navigation surface)
- Must not define governance doctrine, contract schema, lifecycle rules, or platform mechanics

**`xavierlopez.me`**
- Personal portfolio site (Jekyll)
- Uses platform-pipelines shared workflows for CI/CD
- Classified as `portfolio` (external-facing workload)
- Must follow the same contract, validation, and lifecycle model as tenant workloads

### Future Tenants

**`mia`**
- OpenClaw AI assistant workload (not yet created)
- Will be hosted in Kubernetes as platform-governed tenant
- Reserved in taxonomy for future deployment

### Portfolio Contract Governance

**Governance Requirement (Formation v0.1+):**
- Portfolio repositories are contract-governed workloads.
- Portfolio repositories must declare `zave.yaml` and pass the same validation/lifecycle gates as tenant repositories.
- Portfolio repositories may differ in runtime profile (for example `spec.runtime: static`) but not governance level.

**Current Migration Gap:**
- `xavierlopez.me` and `zavestudios` currently lack `zave.yaml`.
- This is a temporary conformance gap in Formation, not a permanent exception.
- Gap closure should be tracked explicitly until both repositories are contract-backed.

**Runtime Profile for Portfolio Workloads:**
- Contract schema supports `spec.runtime: static` for static site workloads.
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
- If portfolio sites cannot use the contract model, that indicates platform incompleteness, not a valid exception.
- Proves contract model works for all workload types, not just API/services.
- Eliminates special-case workflow and governance carve-outs.

**Classification Decision:**
- Repositories may remain `portfolio` for audience/domain clarity.
- `portfolio` does not change enforcement strength.
- Reclassification to `tenant` is optional and should be based on organizational clarity, not governance needs.

---

## Governance Rules

1. Repository category is declared authoritatively in `REPO_TAXONOMY`.

2. Each repository README should reflect its declared category for local clarity, but the taxonomy file remains the canonical source of truth.

3. Reclassification of any repository requires an explicit update to `REPO_TAXONOMY` via pull request.

4. Only `infrastructure` repositories may mutate shared infrastructure state.

5. Only `tenant` and `portfolio` repositories may deploy runtime workloads.

6. `platform-service` repositories provide reusable capabilities and must not define independent business workloads.

7. `portfolio` repositories are subject to the same platform invariants as `tenant` repositories.

8. `index` repositories are pointer-only surfaces and must not introduce architectural or governance authority.

Ambiguity is architectural debt.  
Classification changes must be deliberate and reviewable.
