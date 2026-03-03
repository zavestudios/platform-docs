# ZaveStudios — Enforcement Matrix v0.1

## Purpose

This document maps platform rules to executable enforcement points.

It is an implementation bridge between doctrine and operations.
It does not redefine canonical governance, contract schema, lifecycle semantics, or repository taxonomy.

Canonical authorities:

- `ARCHITECTURAL_DOCTRINE_TIER0.md`
- `CONTRACT_SCHEMA.md`
- `CONTRACT_VALIDATION.md`
- `LIFECYCLE_MODEL.md`
- `REPO_TAXONOMY.md`
- `GENERATOR_MODEL.md`

---

## Enforcement Matrix

| Rule | Control Point | Enforcement Mechanism | Fail Condition | Owner Repo | Block Level |
| --- | --- | --- | --- | --- | --- |
| Workload contract is required for `tenant` and `portfolio` repositories | Tenant/portfolio pull request | CI job validates presence and shape of canonical workload contract | Missing contract, malformed object, missing required keys | `platform-pipelines` | Hard fail |
| Only supported contract versions are accepted | Tenant/portfolio pull request | CI compatibility check against supported `apiVersion` window | Unsupported or deprecated version outside allowed window | `platform-pipelines` | Hard fail |
| Contract semantics must map to supported platform behavior | Tenant/portfolio pull request | Semantic validation stage (runtime/exposure/delivery/capability compatibility) | Unsupported combinations or invalid capability bindings | `platform-pipelines` | Hard fail |
| Tenant/portfolio repositories must use platform-owned workflows | Tenant/portfolio pull request | File-surface and workflow policy checks | Custom workflow definitions or unauthorized workflow call targets | `platform-pipelines` | Hard fail |
| Repository behavior must match declared taxonomy category | Any repository pull request | Taxonomy conformance checks against class invariants | Category/rule mismatch (for example infra mutation in non-infra repo) | `platform-docs` | Hard fail |
| `index` repositories are pointer-only and non-authoritative | Index repository pull request | Content policy check for forbidden authority patterns | Governance doctrine, contract schema, lifecycle rules, or platform mechanics defined in index repo | `platform-docs` | Hard fail |
| Shared infrastructure mutation is constrained to infrastructure layer | Infrastructure/control pull requests | Policy checks + CODEOWNERS + protected branch required checks | Shared infrastructure mutation introduced from non-infrastructure repository | `platform-docs` + org policy | Hard fail |
| Contract changes require compatibility and migration path | `platform-docs` pull request | Documentation gate for compatibility window and migration notes | Contract-breaking change without versioned migration and compatibility updates | `platform-docs` | Hard fail |
| GitOps remains lifecycle authority for deployment state | Runtime reconciliation boundary | Reconciliation policy and drift detection controls | Out-of-band runtime mutation or unmanaged drift | `gitops` | Alert + gated remediation |
| kubectl instructions remain human-gated in docs | Documentation pull request | Markdown lint/policy check for manual-step labeling | kubectl instruction missing required `Run manually by human` label | `platform-docs` | Hard fail |

---

## Control Point Definitions

- **Tenant/portfolio pull request**: validation before merge in workload repositories.
- **Any repository pull request**: validation applied to all repositories regardless of category.
- **Infrastructure/control pull requests**: validation for repositories that can affect shared substrate or governance.
- **Runtime reconciliation boundary**: post-merge enforcement at desired-state reconciliation layer.
- **Documentation pull request**: validation of platform documents and operational guidance.

---

## Rollout Sequence (Recommended)

1. Contract structure and semantic validation gates
2. Workflow ownership and file-surface gates
3. Taxonomy/category conformance gates (including `index`)
4. Contract evolution and migration gates
5. Runtime drift detection and reconciliation evidence export

---

## Evidence Requirements

Each enforcement check should emit machine-verifiable evidence:

- check name and result status
- failing rule identifier
- repository and commit/PR reference
- minimal remediation guidance

Enforcement without evidence is not auditable.
