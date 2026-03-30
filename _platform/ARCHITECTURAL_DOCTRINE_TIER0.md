# ZaveStudios — Tier 0 Architectural Doctrine

## Chapter Guide

**Purpose**

Define the non-negotiable architectural invariants for the platform.

**Read this when**

- deciding whether a proposed platform change is allowed in principle
- checking whether a lower-order document or implementation has crossed a hard boundary
- performing gap analysis against the platform's intended identity

**Read next**

- `OPERATING_MODEL.md` for how these invariants are implemented across repositories
- `CONTROL_PLANE_MODEL.md` for where authority resides at runtime
- `DIAGNOSTIC_MODEL.md` for how to inspect gaps when reality diverges from doctrine

## 1. Identity

ZaveStudios is a reference implementation of an opinionated Internal Developer Platform (IDP) that reduces infrastructure decisions to a bounded declarative contract while guaranteeing delivery, governance, and safe evolution.

It models how elite IDPs convert infrastructure from an ongoing design problem into a constrained, productized interface.

---

## 2. Root Failure Mode

**Unbounded architectural variance across workloads.**

Variance in build pipelines, deployment mechanics, data provisioning, network topology, and governance leads to entropy, fragility, and platform teams devolving into reactive support functions.

ZaveStudios exists to eliminate variance in infrastructure composition while preserving autonomy in application logic.

---

## 3. Architectural Invariants (Non-Negotiable)

ZaveStudios refuses to allow:

- Tenant-defined CI/CD pipelines.
- Unversioned or implicit platform contracts.
- Manual governance bypass.
- Arbitrary infrastructure provisioning.
- More than three deployable units per repository/workload boundary.
- Breaking changes without versioned upgrade paths.
- Free-form ingress or network policy definitions.

Infrastructure composition is platform-owned.

---

## 4. Allowed Variance (Intentionally Bounded)

Tenants may vary:

- Application language and framework.
- Runtime configuration parameters.
- Resource sizing within policy bounds.
- Delivery strategy selection (from platform-defined options).
- Enabled platform capabilities (platform-defined extensions).
- Database selection and sizing (from approved engines).
- Domain and routing configuration (strictly bounded).

Tenants declare intent.  
The platform defines mechanics.

---

## 5. Structural Mechanisms

Variance is constrained through:

- A machine-readable, versioned Workload Contract object
  (`apiVersion` / `kind` / `metadata` / `spec`), conventionally stored as `zave.yaml`.
- Canonical contract structure is defined in
  `CONTRACT_SCHEMA.md` → `Canonical Workload Contract Definition`.
- Schema validation enforced in CI.
- Platform-owned delivery strategies (with contract-version support windows).
- Platform-managed capability modules (extensions).
- Declarative data provisioning with managed secret injection.
- Governance inheritance by default.
- Explicit compatibility windows for contract evolution.

The contract is treated as a product API.

---

## 6. Minimal Workload Principle

A default HTTP service must deploy with five or fewer required infrastructure decisions.

All other platform concerns must default safely.

This enforces low cognitive load and architectural leverage.

Decision model for this principle:

- Structural fields (`apiVersion`, `kind`, `metadata.name`) are not tenant decisions.
- Tenant decisions are tenant-chosen values under `spec`.
- Minimal workload target is three required decisions:
  `spec.runtime`, `spec.exposure`, `spec.delivery`.
- `spec.resources.tier` may be tenant-set but must have a platform default.

---

## 7. Portability Principle

Platform repositories must remain portable across valid environments through
declared interfaces, generated artifacts, and environment-specific overrides.

Portability does not mean identical topology everywhere.
It means the same repository can operate in another approved environment
without redesign or operator-specific hardcoding.

Therefore ZaveStudios must not rely on:

- Personal usernames as shared infrastructure defaults.
- Operator-specific hostnames, LAN IPs, or SSH jump paths committed as the canonical path.
- Environment-specific exceptions hidden in undocumented local shell or SSH state.

Environment-specific access mechanics are allowed only when they are:

- Explicitly modeled as configuration inputs or local overrides.
- Replaceable without changing repository structure or playbook/workload logic.
- Consistent with platform security controls and host identity verification.

---

## 8. Measurable Leverage

ZaveStudios creates leverage by:

- Reducing Time to First Deploy.
- Minimizing infrastructure-specific decisions per workload.
- Enforcing governance automatically.
- Providing predictable upgrade paths via versioned contracts.
- Converting repeated tenant solutions into reusable platform capabilities.

The constrained path must always be faster, safer, and easier than deviation.

---

## See Also

- `OPERATING_MODEL.md`
- `CONTROL_PLANE_MODEL.md`
- `LIFECYCLE_MODEL.md`
- `DIAGNOSTIC_MODEL.md`
