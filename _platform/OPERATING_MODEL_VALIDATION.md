---
title: "OPERATING_MODEL_VALIDATION"
---

# ZaveStudios Operating Model Validation Checklist

This document defines the executable validation checklist for the ZaveStudios operating model.

It must be run according to the Execution Policy defined below.

Validation proceeds in defined order. Governance clarity precedes runtime validation.

---

# MODE A — ROUTINE VALIDATION

Use this for routine checks, release gates, and tenant onboarding.

---

## 1. Documentation Authority

☐ Confirm `platform-docs` is the only repository containing lifecycle definitions  
☐ Confirm no contract schemas exist outside `platform-docs`  
☐ Confirm no versioning policy exists outside `platform-docs`  
☐ Confirm no binding governance language exists in non-governance repos  
☐ Confirm the zavestudios site contains no canonical definitions  

---

## 2. Boundary Enforcement

☐ Confirm each repository has a single layer classification  
☐ Confirm governed audit scope is limited to repositories listed in `REPO_TAXONOMY.md`  
☐ Confirm tenant repos do not define governance rules  
☐ Confirm shared repos do not define lifecycle policy  
☐ Confirm gitops does not define governance semantics  
☐ Confirm the website is not referenced as authoritative by runtime repos  

---

## 3. Instantiation

☐ Create a new tenant using documented artifacts only  
☐ Verify no undocumented steps are required  
☐ Verify contract validation fails explicitly when malformed  
☐ Verify successful tenant reaches deployed state deterministically  

---

## 4. Change Propagation

☐ Introduce a controlled breaking change in a shared workflow  
☐ Identify impacted repositories using documentation only  
☐ Verify version pinning rules are explicit  
☐ Treat any governed repository using floating shared workflow refs as Formation-phase conformance debt until SHA-pinning enforcement is active  
☐ Confirm non-upgraded tenants fail predictably  
☐ Confirm shared repositories do not require operator-specific usernames, IPs, or SSH config as the canonical path  
☐ Confirm no silent behavior changes occur  

---

## 5. Failure Containment

☐ Corrupt a tenant contract and verify validation failure  
☐ Remove a required workflow input and verify explicit failure  
☐ Introduce GitOps drift and verify reconciliation behavior  
☐ Confirm no cross-layer corruption occurs  
☐ Confirm no partial, silent degradation occurs  

---

## 6. Narrative Alignment

☐ Delete the zavestudios site locally — confirm platform remains functional  
☐ Confirm no runtime artifacts depend on website content  
☐ Confirm site does not contain binding policy language  
☐ Confirm governance authority flows only from `platform-docs`  

---

# MODE B — STRUCTURAL AUDIT

Use this after governance mutations, layer refactors, or major architectural changes.

---

## A. Governance Integrity Audit

☐ Repository-wide search for lifecycle terminology outside `platform-docs`  
☐ Repository-wide search for contract YAML duplication  
☐ Repository-wide search for policy keywords ("must comply", "required by policy", etc.)  
☐ Confirm all governance references link to canonical source  

Failure Condition: Any normative governance exists outside `platform-docs`.

---

## B. Layer Purity Audit

For each repository:

Scope rule: only repositories listed in `REPO_TAXONOMY.md` are in scope for governed platform validation. Local workspace directories absent from that table are out of scope unless separately declared authoritative.

☐ Assign explicit layer (Governance / Control Plane / Desired State / Tenant / Interpretation)  
☐ Verify no cross-layer artifact leakage  
☐ Verify no circular authority dependencies  
☐ Verify no runtime dependency on interpretation layer  

Failure Condition: Any repository mixes authority layers.

---

## C. Deterministic Instantiation Audit

☐ Perform full tenant bootstrap from zero state  
☐ Document each step taken  
☐ Confirm steps map directly to documented artifacts  
☐ Confirm no environment-specific knowledge required  
☐ Confirm environment-specific access paths are modeled as declared inputs or local overrides rather than committed operator-specific defaults  

Failure Condition: Hidden or tribal knowledge required.

---

## D. Blast Radius Audit

☐ Modify shared interface signature  
☐ Identify impacted repos using documentation alone  
☐ Confirm blast radius is bounded  
☐ Confirm sequencing rules are documented  
☐ Confirm failure mode is explicit and contained  

Failure Condition: Ambiguous impact or silent degradation.

---

## E. Cross-Layer Failure Simulation

☐ Inject invalid contract schema  
☐ Break shared workflow interface  
☐ Introduce gitops misconfiguration  
☐ Confirm failures are detected at correct layer  
☐ Confirm no corruption propagates upward or downward  

Failure Condition: Cross-layer mutation or undetected invalid state.

---

# EXECUTION POLICY

Validation must be executed under the following conditions:

### Mandatory MODE B (Structural Audit)

Run MODE B when:

- Lifecycle rules change  
- Contract schemas change  
- Versioning policy changes  
- Layer taxonomy changes  
- Authority boundaries change  
- Major control-plane interfaces change  

### MODE A Required

Run MODE A when:

- Onboarding a new tenant  
- Promoting an experiment to tenant  
- Tagging a major release  
- Publishing architectural changes  
- Refactoring tenant scaffolding  

### Scheduled Audit

While the platform is evolving:

- Run MODE B quarterly.

When architecture stabilizes:

- Run MODE B semi-annually.

---

# VALIDATION ORDER

Validation must be executed in this sequence:

1. Documentation Authority  
2. Boundary Enforcement  
3. Instantiation  
4. Change Propagation  
5. Failure Containment  
6. Narrative Alignment  

Runtime validations must not proceed while governance authority is ambiguous.

---

# STABILITY PRINCIPLE

☐ If the `zavestudios` website is deleted, the platform must continue functioning.

☐ If `platform-docs` is deleted, governance must collapse.

This asymmetry is required.

---

# COMPLETION CRITERIA

The operating model is considered validated when:

☐ Governance authority is singular  
☐ Layer boundaries are clean  
☐ Tenant instantiation is deterministic  
☐ Change propagation is predictable  
☐ Failures are contained  
☐ Public narrative does not distort authority
