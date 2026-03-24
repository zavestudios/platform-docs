# Tenant Onboarding Notes

This note captures the stable cross-repo pattern for tenant onboarding without replacing the authoritative doctrine in:
- `REPO_TAXONOMY.md`
- `GITOPS_MODEL.md`
- `CONTROL_PLANE_MODEL.md`
- `CONTRACT_SCHEMA.md`

## Purpose

Tenant onboarding is not a single-repo action.

It is a coordinated lifecycle across:
- tenant repo
- `gitops`
- platform-service repos
- infrastructure repos
- Vault / secret policy

## Stable Pattern

The platform-owned onboarding sequence is:

1. Tenant contract and CI/CD are valid
2. Shared dependencies exist for the tenant’s declared persistence/runtime needs
3. Vault paths are populated for tenant and platform secrets
4. ESO policy is updated to authorize the tenant secret paths
5. `gitops` contains tenant manifests and ArgoCD registration
6. ArgoCD reconciles the tenant
7. Runtime verification confirms the tenant is actually healthy

## Key Constraint

A tenant is not considered onboarded merely because:
- manifests exist in Git
- an ArgoCD Application exists
- secrets exist in Vault

A tenant is onboarded only when:
- dependency paths are real
- ESO can read the required paths
- the runtime becomes healthy in cluster

## Platform Lesson

If the same onboarding failure repeats across multiple tenants, treat it as a platform gap and fix the platform before onboarding more tenants.

Examples observed:
- missing CI-to-GitOps promotion
- missing ESO policy for tenant paths
- missing shared PostgreSQL / Redis services
- shared-service provisioning defaults too strict for real workloads

## Operational Companion

The authoritative operator runbook for the practical sequence lives in:
- `gitops/docs/tenant-onboarding-runbook.md`
