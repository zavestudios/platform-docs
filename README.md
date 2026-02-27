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

- **PLATFORM_OPERATING_MODEL.md**  
  Repository roles, interaction patterns, authority boundaries, and change protocol.

- **LIFECYCLE_MODEL.md**  
  Change sequencing, promotion flow, and compatibility expectations.

- **CONTRACT_SCHEMA.md**  
  Platform interface definitions and required contract structure.

- **CONTRACT_VALIDATION.md**  
  Validation mechanisms and enforcement rules.

- **GENERATOR_MODEL.md**  
  Generator semantics and template-driven behavior.

- **REPO_TOPOLOGY.yaml**  
  Machine-readable inventory of repository roles and dependencies.

## Precedence

In case of conflict, documents are interpreted in the following order:

1. ARCHITECTURAL_DOCTRINE_TIER0.md  
2. PLATFORM_OPERATING_MODEL.md  
3. LIFECYCLE_MODEL.md  
4. CONTRACT_SCHEMA.md  
5. CONTRACT_VALIDATION.md  
6. GENERATOR_MODEL.md  

Lower documents implement or specialize higher ones.

## Change Model

Updates to this repository must be made via pull request.

When modifying:

- Architectural principles → ensure consistency across all dependent documents.
- Contract schema → update validation rules accordingly.
- Shared interaction patterns → assess impact on consumer repositories.
- Lifecycle rules → confirm compatibility and rollout implications.

This repository is expected to evolve deliberately. It is small by design. Mechanical state should be generated elsewhere; conceptual truth lives here.