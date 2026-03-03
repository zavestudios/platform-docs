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

## Document Map

- **ARCHITECTURAL_DOCTRINE_TIER0.md**
  Foundational architectural principles and invariants.

- **REPO_TAXONOMY.md**
  Canonical classification of all repositories in the ZaveStudios organization.

- **OPERATING_MODEL.md**
  Repository roles, interaction patterns, authority boundaries, and change protocol.

- **CONTROL_PLANE_MODEL.md**
  Authority layers, control flow, and exception rules.

- **CONTRACT_SCHEMA.md**
  Platform interface definitions and required contract structure.

- **CONTRACT_VALIDATION.md**
  Validation mechanisms and enforcement rules.

- **LIFECYCLE_MODEL.md**
  Change sequencing, promotion flow, and compatibility expectations.

- **GENERATOR_MODEL.md**
  Generator semantics and template-driven behavior.

- **DEVELOPER_EXPERIENCE.md**
  Canonical developer experience standards for local development.

- **OPERATING_MODEL_VALIDATION.md**
  Executable validation checklist for the operating model.

- **PR_WORKFLOW.md**
  Standard pull request workflow and conventions.

## Precedence

In case of conflict, documents are interpreted in the following order:

1. ARCHITECTURAL_DOCTRINE_TIER0.md
2. CONTROL_PLANE_MODEL.md
3. OPERATING_MODEL.md
4. LIFECYCLE_MODEL.md
5. CONTRACT_SCHEMA.md
6. CONTRACT_VALIDATION.md
7. GENERATOR_MODEL.md

Lower documents implement or specialize higher ones.

Supporting documents (REPO_TAXONOMY.md, DEVELOPER_EXPERIENCE.md, OPERATING_MODEL_VALIDATION.md, PR_WORKFLOW.md) provide operational guidance and do not establish precedence in conflicts.

## Change Model

Updates to this repository must be made via pull request.

When modifying:

- Architectural principles → ensure consistency across all dependent documents.
- Contract schema → update validation rules accordingly.
- Shared interaction patterns → assess impact on consumer repositories.
- Lifecycle rules → confirm compatibility and rollout implications.

This repository is expected to evolve deliberately. It is small by design. Mechanical state should be generated elsewhere; conceptual truth lives here.