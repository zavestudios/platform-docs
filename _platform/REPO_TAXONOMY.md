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
- Shared runtime services used by multiple tenants or platform-managed workloads

They do not represent standalone business workloads.
They may deploy shared runtime components when those components implement reusable platform capability rather than tenant-specific product behavior.

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

### `poc`
Proof-of-concept implementations, technical proposals, and exploratory work.

These are explicitly NOT governed by platform contracts, lifecycle rules, or GitOps.
They exist for demonstration, learning, evaluation, or portfolio purposes.

They may graduate to other categories (tenant, platform-service) if proven viable,
or be archived/deleted when their purpose is fulfilled.

VCS choice (GitHub/GitLab) is orthogonal to category—POCs may live in any approved VCS.

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
| `pg` | platform-service | Possibly | No | Yes | Possibly |
| `zavestudios-architecture` | index | No | No | No | No |
| `cyberark-migration` | poc | Possibly | No | No | Possibly |
| `k8s-mcp` | poc | Possibly | No | No | Possibly |
| `k8s-runtime-security` | poc | Possibly | No | No | Possibly |
| `cloudflare-ai-gateway` | poc | Possibly | No | No | Possibly |

---

## Classification Notes

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

### POC Repositories

POC repositories are exploratory and NOT governed by platform contracts or lifecycle rules.

See:
- **POC_GOVERNANCE.md** for governance model
- **POC_LIFECYCLE.md** for lifecycle states
- **POC_GRADUATION.md** for graduation process

VCS choice is orthogonal—POCs may live in GitLab or GitHub.

### Shared Runtime Platform Services

Platform services may be either:

- non-runtime reusable capabilities, such as pipelines or build primitives
- shared runtime services, such as gateways, provisioners, or other platform-managed APIs used by multiple tenants

Classification rule:

- If the repository provides reusable capability and the running service is shared across workloads, classify it as `platform-service`, not `tenant`.
- If the repository represents tenant-specific or external-facing product behavior, classify it as `tenant` or `portfolio` as appropriate.

Governance implication:

- Shared runtime platform services are still governed through platform-owned GitOps and control-plane rules.
- They are not tenant workloads and should not be modeled as independent business services.

### Tenant Status Notes

**`mia`**
- OpenClaw AI assistant workload (active tenant repository)
- Deploys as a platform-governed tenant via shared workflows and GitOps
- First runtime verification may be tracked separately from repository onboarding status

### Portfolio Contract Governance

**Governance Requirement (Formation v0.1+):**
- Portfolio repositories are contract-governed workloads.
- Portfolio repositories must declare `zave.yaml` and pass the same validation/lifecycle gates as tenant repositories.
- Portfolio repositories may differ in runtime profile (for example `spec.runtime: static`) but not governance level.

**Current Migration Status:**
- `xavierlopez.me` and `zavestudios` are now contract-backed and include `zave.yaml`.
- Portfolio repositories remain subject to the same validation and lifecycle gates as tenant repositories.
- Any future portfolio repository without a canonical workload contract should be treated as a conformance gap, not a permanent exception.

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

5. `tenant` and `portfolio` repositories may deploy workload runtimes. `platform-service` repositories may deploy shared runtime capabilities.

6. `platform-service` repositories provide reusable capabilities and must not define independent business workloads, even when implemented as running services.

7. `portfolio` repositories are subject to the same platform invariants as `tenant` repositories.

8. `index` repositories are pointer-only surfaces and must not introduce architectural or governance authority.

9. `poc` repositories are explicitly NOT subject to platform contracts, lifecycle rules, or GitOps governance. They follow POC-specific governance defined in `POC_GOVERNANCE.md`.

Ambiguity is architectural debt.
Classification changes must be deliberate and reviewable.
