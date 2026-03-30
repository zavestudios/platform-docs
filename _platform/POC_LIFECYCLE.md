# ZaveStudios — POC Lifecycle Model v0.1

This document defines the lifecycle states for POC (proof-of-concept) repositories.

## Chapter Guide

**Purpose**

Define the allowed state transitions for exploratory repositories outside the
governed workload lifecycle.

**Read this when**

- determining where a POC sits in its exploratory path
- deciding whether a repository should archive or graduate
- comparing exploratory lifecycle to governed workload lifecycle

**Read next**

- `POC_GOVERNANCE.md` for quality and exemption rules
- `POC_GRADUATION.md` for the graduation path
- `LIFECYCLE_MODEL.md` for the governed lifecycle that POCs do not follow

POC lifecycle is simpler than platform workload lifecycle. POCs are exploratory and not subject to contract validation, generators, or GitOps reconciliation.

---

## POC Lifecycle vs Platform Workload Lifecycle

**Platform Workload Lifecycle** (from `LIFECYCLE_MODEL.md`):
```
Draft → Validated → Generated → Registered → Deployed → Promoted → Updated → Suspended → Decommissioned
```
- Contract-driven
- Validation gates at each stage
- Generator involvement
- GitOps authority
- Production-ready requirements

**POC Lifecycle** (this document):
```
Draft → Active → [Archived | Graduated]
```
- Exploration-driven
- Minimal gates
- No generator involvement
- No GitOps requirement
- Portfolio/learning-ready requirements

---

## Lifecycle States

A POC moves through three primary states:

### 1. Draft
### 2. Active
### 3. Terminal States: Archived or Graduated

---

## State 1 — Draft

**Entry condition:**
- POC repository created
- README created with System Design Interview template structure

**Characteristics:**
- Problem statement drafted
- Exploration just beginning
- No code may exist yet
- Recommendation not yet formed

**README Status Field:**
```markdown
**Status:** Draft
```

**Activities in this state:**
- Research alternatives
- Draft architecture options
- Gather requirements
- Define success criteria

**Exit trigger:**
- Implementation begins, OR
- Research progresses to comparing concrete alternatives

---

## State 2 — Active

**Entry condition:**
- POC has clear problem statement
- At least one approach is being implemented or evaluated
- Success criteria are defined

**Characteristics:**
- Implementation in progress
- Alternatives being compared
- Trade-offs being documented
- Code may or may not exist (documentation POCs are valid)

**README Status Field:**
```markdown
**Status:** Active
```

**Activities in this state:**
- Implement proof-of-concept code
- Test hypotheses
- Document trade-offs
- Gather evidence for recommendation

**Exit trigger:**
- Recommendation is reached (adopt, defer, reject), OR
- POC is abandoned (no activity for extended period)

---

## State 3A — Archived

**Entry condition:**
- POC recommendation is "defer" or "reject", OR
- POC purpose is fulfilled and does not warrant graduation, OR
- POC abandoned with no activity for >12 months

**Characteristics:**
- POC is complete but not adopted
- Serves as historical reference
- Design thinking preserved for future reference
- Repository remains accessible but development ceases

**README Status Field:**
```markdown
**Status:** Archived
**Reason:** [Recommendation was reject | Purpose fulfilled | Abandoned]
**Date:** [YYYY-MM-DD]
```

**Actions performed:**
- Update README with final status
- Document recommendation and reasoning
- Add archive notice to repository description
- No code/files deleted (preserved for reference)

**Example Archive Notice:**

```markdown
## Archive Notice

This POC has been archived.

**Recommendation:** Do not adopt Cloudflare AI Gateway at this time.

**Reasoning:**
- Latency overhead (50-100ms) unacceptable for synchronous AI interactions
- Lock-in risk outweighs observability benefits
- Self-hosted alternative (LiteLLM) provides better GitOps alignment

**Future Review:** Re-evaluate if async AI workloads become dominant use case.

**Archived:** 2026-03-12
```

---

## State 3B — Graduated

**Entry condition:**
- POC recommendation is "adopt"
- POC has proven concept viable
- Decision made to move to production implementation

**Characteristics:**
- POC served its purpose successfully
- Implementation migrates to contract-governed repository
- POC repository becomes historical record of design process
- Archived with graduation link

**README Status Field:**
```markdown
**Status:** Graduated
**Graduated To:** [tenant | platform-service | infrastructure]
**New Repository:** [Link to contract-governed repo]
**Date:** [YYYY-MM-DD]
```

**Actions performed:**
- Create new contract-governed repository (see `POC_GRADUATION.md`)
- Migrate implementation code to new repo
- Update POC README with graduation notice
- Archive POC repository

**Example Graduation Notice:**

```markdown
## Graduation Notice

This POC has successfully graduated to a platform-governed tenant workload.

**Recommendation:** Adopt k8s-runtime-security as platform security capability.

**New Repository:** https://github.com/zavestudios/k8s-runtime-security

**Graduation Date:** 2026-06-15

**Implementation Status:** Deployed to production cluster, monitoring active.

---

This repository remains as historical record of the design process and architectural evaluation.
```

---

## Lifecycle Flow Summary

```
┌────────────────────────────────────────────────────────────┐
│                       POC Lifecycle                         │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐          ┌──────────┐                        │
│  │  Draft   │─────────▶│  Active  │                        │
│  │          │          │          │                        │
│  └──────────┘          └────┬─────┘                        │
│                             │                              │
│                   ┌─────────┴─────────┐                    │
│                   │                   │                    │
│                   ▼                   ▼                    │
│            ┌────────────┐      ┌────────────┐             │
│            │  Archived  │      │ Graduated  │             │
│            │  (reject/  │      │ (adopt &   │             │
│            │   defer)   │      │  migrate)  │             │
│            └────────────┘      └────────────┘             │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

---

## Lifecycle Transitions

### Draft → Active

**Trigger:** Implementation or evaluation begins

**Actions:**
- Update README status: `Draft` → `Active`
- Commit initial code or architecture diagrams
- Document at least one approach being evaluated

### Active → Archived

**Trigger:** Recommendation is defer/reject, or POC abandoned

**Actions:**
- Update README status: `Active` → `Archived`
- Add archive notice with reasoning
- Update repository description: "(Archived)"
- No deletion—preserved for reference

### Active → Graduated

**Trigger:** Recommendation is adopt

**Actions:**
- Follow graduation process (`POC_GRADUATION.md`)
- Create new contract-governed repository
- Migrate code to new repo
- Update README status: `Active` → `Graduated`
- Add graduation notice with link to new repo
- Archive POC repository

---

## State Invariants

**POCs must guarantee:**
- Every POC has a defined status (Draft, Active, Archived, or Graduated)
- Status is visible in README metadata
- Archived/Graduated POCs include reason and date
- No POC remains in Active state indefinitely without progress

---

## Review and Cleanup Policy

**Review Schedule:**
- Active POCs older than 6 months → Review progress, update status or archive
- Draft POCs older than 3 months with no activity → Archive as abandoned

**Cleanup Criteria:**
- Archived: No deletion, preserved as reference
- Graduated: No deletion, preserved as design history

POCs are **never deleted**—they serve as organizational knowledge artifacts.

---

## Comparison to Platform Workload Lifecycle

| Aspect | Platform Workload | POC |
|--------|------------------|-----|
| **States** | 9 states (Draft → Decommissioned) | 3 states (Draft → Active → Archived/Graduated) |
| **Validation** | Multi-stage schema/semantic/policy validation | No validation (freedom to explore) |
| **Generators** | Required (repo/pipeline/GitOps/capability) | Not involved |
| **GitOps** | Authoritative lifecycle control | Not registered |
| **Contract** | `zave.yaml` required | No contract |
| **Deployment** | Production runtime | May deploy for demo/testing only |
| **Goal** | Reliable production operation | Learning, evaluation, portfolio demonstration |

---

## Lifecycle Invariants

POC lifecycle must guarantee:

- Every POC repository has explicit status in README
- Status transitions are documented with dates
- Archived/Graduated POCs include reasoning
- No POCs remain Active indefinitely without review

---

## Strategic Role

POC lifecycle ensures:

- **Exploration has boundaries** — POCs don't drift indefinitely
- **Decisions are captured** — Archived POCs document "why not"
- **Success is traceable** — Graduated POCs link to production implementations
- **Knowledge is preserved** — Nothing is deleted, all design thinking retained

POC lifecycle converts experimentation from chaos into a repeatable, documented process.

---

## Related Documentation

- **POC_GOVERNANCE.md** — POC governance model and requirements
- **POC_GRADUATION.md** — Graduation process from POC to contract-governed repo
- **LIFECYCLE_MODEL.md** — Platform workload lifecycle (what POCs are exempt from)
- **REPO_TAXONOMY.md** — Repository classification including POC category

---

## See Also

- `POC_GOVERNANCE.md`
- `POC_GRADUATION.md`
- `LIFECYCLE_MODEL.md`
- `REPO_TAXONOMY.md`
