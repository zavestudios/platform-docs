# Terraform Policy Automation (No-Cost Path)

This runbook applies class-based branch protection to Terraform repositories when
organization-level rulesets are not available.

## Class Model

Terraform repositories use topic-based class tags:

- `modules`
- `sandbox`
- `production`

All Terraform repos must also include the `terraform` topic.

## Enforcement Applied

For the repository default branch:

- Enforce admins
- Require pull request review
- Dismiss stale approvals on push
- Require conversation resolution
- Require linear history
- Disallow force pushes
- Disallow deletions

Class-specific review policy:

- `sandbox`: 1 approval, code owner review not required
- `modules`: 1 approval, code owner review required
- `production`: 2 approvals, code owner review required

## Scripts

- `scripts/apply-terraform-repo-protection.sh`
  - Apply policy to one repository.
- `scripts/apply-terraform-repo-protection-bulk.sh`
  - Apply policy to all repos in an org with `terraform` topic.

## Usage

Run manually by human:

```bash
# Single repo
./scripts/apply-terraform-repo-protection.sh zavestudios iac-tf-sbx-example

# Bulk apply for org
./scripts/apply-terraform-repo-protection-bulk.sh zavestudios
```

## Prerequisites

- `gh` authenticated as a user with admin permission on target repositories
- `jq` installed
