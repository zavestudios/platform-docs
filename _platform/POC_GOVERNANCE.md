# ZaveStudios — POC Governance Model v0.1

This document defines the governance model for POC (proof-of-concept) repositories.

## Chapter Guide

**Purpose**

Define how exploratory repositories are governed outside the normal platform
contract path.

**Read this when**

- deciding whether work should remain a POC or enter governed platform scope
- reviewing what POCs are exempt from
- setting expectations for exploratory repository quality and lifecycle

**Read next**

- `POC_LIFECYCLE.md` for state transitions
- `POC_GRADUATION.md` for the move into governed categories
- `REPO_TAXONOMY.md` for where POCs sit relative to the governed repo model

POC repositories are exploratory and explicitly NOT governed by platform contracts, lifecycle rules, or GitOps reconciliation.

---

## Purpose

POC repositories serve the following purposes:

- **Technical proposals:** Evaluate whether to adopt a technology or architecture
- **Architectural exploration:** Compare multiple approaches before committing
- **Skill demonstration:** Build portfolio-quality implementations
- **Research spikes:** Answer specific technical questions through implementation

POCs are time-bounded or outcome-bounded experiments.

---

## Governance Exemptions

POCs are exempt from the following platform requirements:

- **No contract required:** POCs do not need `zave.yaml`
- **No GitOps registration:** POCs do not register in `gitops` repository
- **No lifecycle validation:** POCs do not pass through contract validation gates
- **No shared workflow requirement:** POCs may use shared workflows if beneficial, but it's not mandatory
- **VCS flexibility:** POCs may live in GitLab or GitHub (VCS choice is orthogonal to category)

---

## Required Artifacts

All POC repositories MUST include:

### 1. README.md with System Design Interview Template

POCs must follow this structure:

```markdown
# [POC Name]

**Status:** [Draft | Active | Archived | Graduated]
**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Governance:** [Link to this document]

---

## Step 1: Understand the Problem and Design Scope

### Problem Statement
[What problem are you solving or exploring?]

### Constraints and Requirements
- [ ] Requirement 1
- [ ] Requirement 2

### Out of Scope / Non-Goals
[What this POC explicitly does NOT address]

### Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2

---

## Step 2: Propose High-Level Design and Get Buy-In

### System Architecture
[Diagram or description]

### Key Components
[Component breakdown]

### Technology Choices and Rationale
[Why these technologies?]

### Trade-offs Considered
[What alternatives were considered and why not chosen?]

---

## Step 3: Design Deep Dive

[Detailed implementation breakdown]

---

## Step 4: Wrap Up

### Summary of Solution
[Brief recap]

### Limitations and Known Gaps
[What's missing or incomplete?]

### Future Improvements
[What would be needed for production?]

### Governance Metadata
- **Status:** [Current status]
- **Graduation Target:** [tenant | platform-service | N/A | Archived]
- **Review Date:** [When to revisit]
```

**Rationale:**
- Consistent structure across all POCs
- Forces problem definition before jumping to implementation
- Documents design thinking, not just code
- Creates portfolio-quality artifacts
- Industry-standard template (recognizable to interviewers/reviewers)

### 2. Governance Metadata

Every POC README must include this metadata block:

- **Status:** Draft, Active, Archived, or Graduated
- **Author:** Person responsible
- **Date:** Creation date
- **Governance:** Link to this document

### 3. CI Validation (Optional)

POCs may include GitLab CI or GitHub Actions to validate:
- README structure exists
- Required sections present
- Metadata filled in

Example GitLab CI:

```yaml
validate-poc:
  script:
    - test -f README.md || exit 1
    - grep -q "## Step 1: Understand the Problem" README.md || exit 1
    - grep -q "## Step 2: Propose High-Level Design" README.md || exit 1
    - grep -q "## Step 3: Design Deep Dive" README.md || exit 1
    - grep -q "## Step 4: Wrap Up" README.md || exit 1
    - grep -q "**Status:**" README.md || exit 1
```

---

## POC Lifecycle States

POCs move through simplified states (see `POC_LIFECYCLE.md` for details):

1. **Draft** — Idea/exploration phase
2. **Active** — Implementation in progress
3. **Archived** — Completed, recommendation was reject/defer
4. **Graduated** — Migrated to contract-governed category

---

## Quality Standards

### Minimum Viable POC

A POC is considered complete when:

- [ ] README follows System Design Interview template
- [ ] Problem statement is clear
- [ ] At least 2 alternatives are compared with trade-offs
- [ ] Recommendation is explicit (adopt/defer/reject)
- [ ] Governance metadata is filled in

### Code Quality

POCs are NOT held to production code standards, but should:

- Be readable and understandable
- Include comments where logic is not obvious
- Work as demonstrated (no broken implementations)

### Documentation Over Code

POCs prioritize **design thinking documentation** over production-ready code.

A well-documented architecture comparison with no code is more valuable than uncommented code with no explanation.

---

## Graduation Process

When a POC is validated and ready for production adoption, it graduates to a contract-governed category.

See `POC_GRADUATION.md` for the full graduation process.

**Summary:**
1. POC proves concept viable
2. Create new contract-governed repository (via generator or manual scaffold)
3. Migrate implementation code to new repo
4. Archive POC repo with "Graduated to: [repo-url]"

---

## Review and Cleanup Policy

POCs should be reviewed periodically:

**Suggested Review Schedule:**
- Every 6 months, review all Active POCs
- Decide: Continue, Graduate, or Archive

**Cleanup Criteria:**
- POC older than 1 year without activity → Archive
- POC recommendation is "reject" → Archive
- POC graduated successfully → Archive with graduation link

---

## VCS and Location

**Current Practice:**
- POCs live in GitLab (`gitlab.com/zavestudios/poc/`)
- Platform-governed repos live in GitHub

**Future Flexibility:**
- VCS choice is orthogonal to category
- POCs MAY live in GitHub if needed
- Decision is organizational preference, not technical requirement

---

## Relationship to Platform Governance

### What POCs Share with Platform

- General engineering quality expectations
- Respectful communication standards
- Security awareness (no secrets in repos, etc.)

### What POCs Do NOT Share

- Contract schema compliance
- Lifecycle validation gates
- GitOps reconciliation
- Generator involvement
- Shared workflow requirements

---

## Enforcement

**Manual (Formation Phase):**
- PR reviews check for README structure
- Checklist: "Does this POC have required README sections?"
- Reference this document in review comments

**Automated (Target State):**
- CI validation checks README structure
- Bot comments on PRs missing required sections
- Dashboard shows POC health (metadata present, review date passed, etc.)

---

## Strategic Role

POC governance converts experimentation from ad-hoc exploration into a repeatable, documented process.

Without POC governance:
- Experiments live in personal repos with no organizational visibility
- Design thinking is lost (only code remains)
- Decisions are made without documented alternatives
- Knowledge is siloed with individuals

With POC governance:
- Experiments are visible and discoverable
- Design thinking is captured and reusable
- Decisions are documented with trade-offs
- Knowledge is organizational, not individual

POCs are portfolio assets. They demonstrate not just "can you code?" but "can you think architecturally?"

---

## Related Documentation

- **POC_LIFECYCLE.md** — POC state transitions
- **POC_GRADUATION.md** — Graduation process from POC to contract-governed repo
- **REPO_TAXONOMY.md** — Canonical repository classification
- **OPERATING_MODEL.md** — Platform workload governance (what POCs are exempt from)

---

## See Also

- `POC_LIFECYCLE.md`
- `POC_GRADUATION.md`
- `REPO_TAXONOMY.md`
- `OPERATING_MODEL.md`
