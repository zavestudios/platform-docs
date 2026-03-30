# ZaveStudios Platform Docs

This repository is the authoritative source of truth for the ZaveStudios platform operating model, contracts, and architectural governance.

It defines how the platform is structured, how repositories interact, and how change is introduced safely across the system. It does not contain application code or environment-specific secrets.

For local multi-repository analysis in this workspace, the current working set is defined by `/path/to/my/vscode.code-workspace`. That file is an operational workspace definition, not a governance authority.

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

- Start with the reading path that matches your task.
- Use the grouped table of contents below to move laterally across related topics.
- Use the precedence section only to resolve conflicts between documents.

## Reading Paths

### New Operator Or Agent

1. `ARCHITECTURAL_DOCTRINE_TIER0.md`
2. `OPERATING_MODEL.md`
3. `CONTROL_PLANE_MODEL.md`
4. `DEVELOPER_EXPERIENCE.md`
5. `EXECUTION_ENVIRONMENTS.md`
6. `PR_WORKFLOW.md`

### Gap Analysis

1. `ARCHITECTURAL_DOCTRINE_TIER0.md`
2. `CONTROL_PLANE_MODEL.md`
3. `DIAGNOSTIC_MODEL.md`
4. `RUNBOOK_METHODOLOGY.md`
5. `EXECUTION_ENVIRONMENTS.md`
6. `ENFORCEMENT_MATRIX.md`
7. `OPERATING_MODEL_VALIDATION.md`

### Incident Response And Troubleshooting

1. `CONTROL_PLANE_MODEL.md`
2. `DIAGNOSTIC_MODEL.md`
3. `RUNBOOK_METHODOLOGY.md`
4. `EXECUTION_ENVIRONMENTS.md`
5. `GITOPS_MODEL.md`
6. `OPERATING_MODEL_VALIDATION.md`

### Contract And Generator Work

1. `CONTRACT_SCHEMA.md`
2. `CONTRACT_VALIDATION.md`
3. `GENERATOR_MODEL.md`
4. `LIFECYCLE_MODEL.md`
5. `GITOPS_MODEL.md`

## Table Of Contents

### Doctrine

- **ARCHITECTURAL_DOCTRINE_TIER0.md**
  Foundational architectural principles and invariants.
- **OPERATING_MODEL.md**
  Repository roles, interaction patterns, authority boundaries, and change protocol.
- **CONTROL_PLANE_MODEL.md**
  Authority layers, control flow, and exception rules.
- **DIAGNOSTIC_MODEL.md**
  Diagnostic reasoning model and gap-analysis lens across control-plane boundaries.

### Contracts And Generation

- **CONTRACT_SCHEMA.md**
  Platform interface definitions and required contract structure.
- **CONTRACT_VALIDATION.md**
  Validation mechanisms and enforcement rules.
- **GENERATOR_MODEL.md**
  Generator semantics and template-driven behavior.
- **GITOPS_MODEL.md**
  How authoritative desired state is represented and advanced through GitOps.

### Execution And Operations

- **DEVELOPER_EXPERIENCE.md**
  Canonical developer experience standards for local development.
- **DEVELOPER_EXPERIENCE_JOURNEYS.md**
  User-journey appendix for developer workflows and DX gap analysis.
- **EXECUTION_ENVIRONMENTS.md**
  Canonical execution environments, available tools, and where platform operations should run.
- **PR_WORKFLOW.md**
  Standard pull request workflow and conventions.
- **RUNBOOK_METHODOLOGY.md**
  Guidance for when runbooks should be created and how incident knowledge should be captured.
- **OPERATING_MODEL_VALIDATION.md**
  Executable validation checklist for the operating model.

### Lifecycle And Governance

- **REPO_TAXONOMY.md**
  Canonical classification of all repositories in the ZaveStudios organization.
- **LIFECYCLE_MODEL.md**
  Change sequencing, promotion flow, and compatibility expectations.
- **ENFORCEMENT_MATRIX.md**
  Where platform rules are enforced and what remains advisory.
- **POC_GOVERNANCE.md**
  Governance expectations for proof-of-concept work.
- **POC_GRADUATION.md**
  Conditions for promotion from proof-of-concept to supported platform path.
- **POC_LIFECYCLE.md**
  Lifecycle expectations and boundaries for proof-of-concept efforts.

### Measurement And Feedback

- **MEASUREMENT_MODEL.md**
  What platform outcomes should be measured and why.
- **FRICTION_FEEDBACK.md**
  Core policy for how friction is captured and turned into platform improvement.
- **FRICTION_FEEDBACK_PLAYBOOK.md**
  Operational playbook, templates, and recurring review flow for friction handling.
- **AUDIT_PROGRAM.md**
  Audit expectations for platform behavior and evidence collection.

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

This precedence list is intentionally a conflict-resolution subset, not a complete inventory of `_platform/`. See the table of contents above for the broader file set.

Supporting documents such as `REPO_TAXONOMY.md`, `DEVELOPER_EXPERIENCE.md`, `OPERATING_MODEL_VALIDATION.md`, `PR_WORKFLOW.md`, `DIAGNOSTIC_MODEL.md`, `RUNBOOK_METHODOLOGY.md`, and `EXECUTION_ENVIRONMENTS.md` provide operating guidance and do not establish precedence in conflicts.

## Change Model

Updates to this repository must be made via pull request.

When modifying:

- Architectural principles → ensure consistency across all dependent documents.
- Contract schema → update validation rules accordingly.
- Shared interaction patterns → assess impact on consumer repositories.
- Lifecycle rules → confirm compatibility and rollout implications.

This repository is expected to evolve deliberately. It is small by design. Mechanical state should be generated elsewhere; conceptual truth lives here.
