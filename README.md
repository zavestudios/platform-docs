# ZaveStudios Platform Docs

This repository is the authoritative source of truth for the ZaveStudios platform operating model, contracts, and architectural governance.

It defines how the platform is structured, how repositories interact, and how change is introduced safely across the system. It does not contain application code or environment-specific secrets.

## Scope

This repository governs:

- Architectural principles and non-negotiable constraints  
- Cross-repository interaction patterns  
- Platform contracts and schema definitions  
- Validation and enforcement expectations  
- Lifecycle and change sequencing rules  
- Generator and scaffolding behavior  

It does not replace per-repo documentation for service-specific implementation details.

## How To Use This Handbook

Read this repository like a small canonical handbook, not a wiki.

- Use the grouped table of contents below to move laterally across related topics.
- Use the precedence section only to resolve conflicts between documents.

## Table Of Contents

### Doctrine

- [ARCHITECTURAL_DOCTRINE_TIER0.md](_platform/ARCHITECTURAL_DOCTRINE_TIER0.md)
  Foundational architectural principles and invariants.
- [OPERATING_MODEL.md](_platform/OPERATING_MODEL.md)
  Repository roles, interaction patterns, authority boundaries, and change protocol.
- [CONTROL_PLANE_MODEL.md](_platform/CONTROL_PLANE_MODEL.md)
  Authority layers, control flow, and exception rules.
- [DIAGNOSTIC_MODEL.md](_platform/DIAGNOSTIC_MODEL.md)
  Diagnostic reasoning model and gap-analysis lens across control-plane boundaries.

### Contracts And Generation

- [CONTRACT_SCHEMA.md](_platform/CONTRACT_SCHEMA.md)
  Platform interface definitions and required contract structure.
- [GENERATOR_MODEL.md](_platform/GENERATOR_MODEL.md)
  Generator semantics and template-driven behavior.

### Platform Behavior

- [GITOPS_MODEL.md](_platform/GITOPS_MODEL.md)
  How authoritative desired state is represented and advanced through GitOps.
- [ADMISSION_POLICY_MODEL.md](_platform/ADMISSION_POLICY_MODEL.md)
  Kyverno mutate and validate authoring patterns, and what is enforced versus audited.
- [OBSERVABILITY_MODEL.md](_platform/OBSERVABILITY_MODEL.md)
  Classification, ownership, and capability materialization rules for logs, metrics, and traces.
- [observability/OBSERVABILITY_DATA_FLOW.md](_platform/observability/OBSERVABILITY_DATA_FLOW.md)
  Runtime shape of the observability stack: what pushes, what scrapes, where signals are stored.

### Operations

- [REPO_TAXONOMY.md](_platform/REPO_TAXONOMY.md)
  Canonical classification of all repositories in the ZaveStudios organization.

## Precedence

In case of conflict, documents are interpreted in the following order:

1. ARCHITECTURAL_DOCTRINE_TIER0.md
2. CONTROL_PLANE_MODEL.md
3. OPERATING_MODEL.md
4. CONTRACT_SCHEMA.md
5. GENERATOR_MODEL.md

Lower documents implement or specialize higher ones.

This precedence list is intentionally a conflict-resolution subset, not a complete inventory of `_platform/`. See the table of contents above for the broader file set.

Supporting documents such as [`REPO_TAXONOMY.md`](_platform/REPO_TAXONOMY.md) and [`DIAGNOSTIC_MODEL.md`](_platform/DIAGNOSTIC_MODEL.md) provide operating guidance and do not establish precedence in conflicts.

## Change Model

Updates to this repository must be made via pull request.

When modifying:

- Architectural principles → ensure consistency across all dependent documents.
- Contract schema → update validation rules accordingly.
- Shared interaction patterns → assess impact on consumer repositories.
- Lifecycle rules → confirm compatibility and rollout implications.

This repository is expected to evolve deliberately. It is small by design. Mechanical state should be generated elsewhere; conceptual truth lives here.
