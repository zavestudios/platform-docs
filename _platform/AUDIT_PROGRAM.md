---
title: "AUDIT_PROGRAM"
---

# ZaveStudios Audit Program

This document defines the canonical audit and assessment program for the ZaveStudios platform.

It answers four questions:

1. What audits exist
2. When each audit is required
3. What each audit must verify
4. What output each audit must produce

This document is the execution map for platform review work.

It does not replace canonical governance, contract, lifecycle, or control-plane definitions.
It tells humans and agents which canonical documents to apply, and when.

---

## Scope Rule

Governed platform audits apply only to repositories listed in `REPO_TAXONOMY.md`.

Local workspace directories absent from the taxonomy table are out of scope unless separately declared authoritative by a canonical platform document.

---

## Audit Catalog

### 1. Repository Scope Audit

Purpose:

- Confirm the governed repository set is explicit and current
- Confirm repository classification is canonical and unambiguous

Primary authorities:

- `REPO_TAXONOMY.md`
- `OPERATING_MODEL_VALIDATION.md`

Required checks:

- Every in-scope governed repository appears in `REPO_TAXONOMY.md`
- Each listed repository has exactly one category
- Repositories absent from taxonomy are not treated as governed drift
- Any reclassification or scope change is reviewable through pull request

Output:

- in-scope repository table
- out-of-scope repository note
- classification drift findings

---

### 2. Authority Audit

Purpose:

- Confirm governance authority is singular
- Confirm canonical definitions are not duplicated or redefined elsewhere

Primary authorities:

- `ARCHITECTURAL_DOCTRINE_TIER0.md`
- `CONTRACT_SCHEMA.md`
- `CONTRACT_VALIDATION.md`
- `LIFECYCLE_MODEL.md`
- `REPO_TAXONOMY.md`
- `OPERATING_MODEL_VALIDATION.md`

Required checks:

- `platform-docs` is the only authoritative source for governance doctrine
- No contract schema definitions exist outside `platform-docs`
- No lifecycle definitions exist outside `platform-docs`
- Narrative/index surfaces link to canonical authority without redefining it

Output:

- authority findings
- duplicate-definition findings
- canonical-reference findings

---

### 3. Control-Plane Boundary Audit

Purpose:

- Confirm each repository stays inside its assigned control-plane role
- Confirm policy, state, and execution concerns do not leak across layers

Primary authorities:

- `CONTROL_PLANE_MODEL.md`
- `GITOPS_MODEL.md`
- `REPO_TAXONOMY.md`
- `OPERATING_MODEL_VALIDATION.md`

Required checks:

- `platform-docs` defines doctrine and governance only
- `platform-pipelines` validates/builds/proposes but does not define tenant lifecycle policy
- `gitops` owns desired state and lifecycle registration, not governance doctrine
- infrastructure repositories mutate substrate only
- tenant and portfolio repositories declare intent and consume workflows without defining platform mechanics

Output:

- per-repository layer assignment
- boundary-leakage findings
- control-plane exception list

---

### 4. Contract and Conformance Audit

Purpose:

- Confirm governed workload repositories satisfy baseline contract and DX requirements

Primary authorities:

- `CONTRACT_SCHEMA.md`
- `CONTRACT_VALIDATION.md`
- `DEVELOPER_EXPERIENCE.md`
- `ENFORCEMENT_MATRIX.md`
- `REPO_TAXONOMY.md`

Required checks:

- `tenant` and `portfolio` repositories contain canonical `zave.yaml`
- Shared workflow bindings are present and platform-owned
- Required local development files exist
- README local development guidance exists where required

Output:

- conformance matrix
- missing-artifact findings
- deferred conformance debt list

---

### 5. Change-Propagation Audit

Purpose:

- Confirm shared-interface changes have bounded, explicit blast radius

Primary authorities:

- `OPERATING_MODEL_VALIDATION.md`
- `ENFORCEMENT_MATRIX.md`
- `ARCHITECTURAL_DOCTRINE_TIER0.md`

Required checks:

- Shared workflow consumers can be identified from documentation and repository content
- Contract-version blast radius is explicit
- Version pinning rules are explicit
- Non-upgraded consumers fail predictably
- Floating shared workflow refs are treated as Formation-phase conformance debt until SHA-pinning enforcement is active

Output:

- impacted repository list
- sequencing/risk note
- undocumented blast-radius findings

---

### 6. GitOps and Lifecycle Audit

Purpose:

- Confirm deployment state and workload lifecycle remain Git-driven

Primary authorities:

- `LIFECYCLE_MODEL.md`
- `GITOPS_MODEL.md`
- `CONTROL_PLANE_MODEL.md`
- `ENFORCEMENT_MATRIX.md`

Required checks:

- GitOps remains the operational state authority
- Runtime state is representable in Git
- Documented manual exceptions are explicitly human-gated
- No steady-state workflow bypasses GitOps

Output:

- lifecycle/GitOps findings
- manual-step inventory
- state-authority violations

---

### 7. Narrative Alignment Audit

Purpose:

- Confirm public and interpretive surfaces explain the platform without becoming authority layers

Primary authorities:

- `OPERATING_MODEL_VALIDATION.md`
- `REPO_TAXONOMY.md`

Required checks:

- `zavestudios` is not treated as canonical governance
- public docs do not define binding policy
- deleting the public narrative layer would not break platform function

Output:

- narrative authority findings
- drift-prone interpretation notes

---

## Execution Triggers

Use the following trigger matrix.

| Trigger | Required Audits |
| --- | --- |
| Repository taxonomy change | Repository Scope Audit, Authority Audit, Control-Plane Boundary Audit |
| Contract schema change | Authority Audit, Contract and Conformance Audit, Change-Propagation Audit |
| Contract validation rule change | Authority Audit, Contract and Conformance Audit, Change-Propagation Audit |
| Shared workflow interface change | Change-Propagation Audit, Control-Plane Boundary Audit |
| GitOps model change | Control-Plane Boundary Audit, GitOps and Lifecycle Audit |
| Lifecycle model change | Authority Audit, Control-Plane Boundary Audit, GitOps and Lifecycle Audit |
| Major control-plane interface change | Control-Plane Boundary Audit, Change-Propagation Audit |
| Tenant onboarding or promotion from experiment/POC | Repository Scope Audit, Contract and Conformance Audit, GitOps and Lifecycle Audit |
| Publishing major architectural changes | Authority Audit, Narrative Alignment Audit, Change-Propagation Audit |
| Quarterly during Formation | Full structural audit: Repository Scope, Authority, Control-Plane Boundary, Contract and Conformance, Change-Propagation, GitOps and Lifecycle, Narrative Alignment |

---

## Audit Modes

### Routine Audit

Use for:

- tenant onboarding
- release gating
- targeted repository review

This mode may run only the audits required by the trigger matrix.

### Structural Audit

Use for:

- taxonomy changes
- authority-boundary changes
- contract/lifecycle model changes
- major platform refactors

This mode should run the full set of required audits in the trigger matrix and record explicit findings, exceptions, and debt.

---

## Required Evidence

Every audit output must include:

- audit name
- trigger for execution
- in-scope repositories
- canonical authorities consulted
- findings ordered by severity
- explicit Formation exceptions or deferred debt
- remediation recommendations
- manual human steps, if any
- audit date

Audits without evidence are advisory, not authoritative.

---

## Formation Exceptions

During Formation, temporary exceptions may exist.

Rules for exceptions:

- They must be documented canonically in `platform-docs`
- They must identify the target steady state
- They must be treated as explicit conformance debt, not silent normal behavior
- They must be reviewable and removable

Undocumented exceptions are audit failures.

---

## Review Cadence

While the platform remains in Formation:

- run trigger-based audits whenever a trigger condition occurs
- run a quarterly structural audit

After Formation exits:

- continue trigger-based audits
- run a semi-annual structural audit unless replaced by stricter automated enforcement

---

## Completion Standard

An audit is complete only when:

- scope is explicit
- canonical authorities are cited
- findings and exceptions are recorded
- remediation or acceptance is explicit

If an audit discovers a gap but does not record whether it is a failure, accepted exception, or deferred work item, the audit is incomplete.
