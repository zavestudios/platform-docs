# ZaveStudios — Platform Measurement Model v0.1

This document defines the canonical metrics and measurement practices for the ZaveStudios platform.

## Chapter Guide

**Purpose**

Define which platform outcomes are measured, why they matter, and how they
should influence decisions.

**Read this when**

- evaluating whether the platform is improving in meaningful ways
- selecting metrics for a gap analysis, audit, or quarterly review
- deciding whether a metric supports a real decision or just reporting theater

**Read next**

- `FRICTION_FEEDBACK.md` for a key measurement input loop
- `AUDIT_PROGRAM.md` for review cadence and evidence framing
- `DEVELOPER_EXPERIENCE_JOURNEYS.md` for journey-based targets

It exists to:

- Track platform health and effectiveness
- Measure developer productivity and satisfaction
- Validate architectural decisions
- Guide continuous improvement
- Inform Formation phase exit criteria

Measurement is required to distinguish platform success from platform theater.

---

## Measurement Principles

### 1. Metrics Must Drive Decisions

Metrics exist to inform platform evolution, not to create reporting theater.

If a metric does not influence platform priorities or architecture, it should not be tracked.

### 2. Developer Experience is Primary

Platform success is measured by tenant productivity and satisfaction, not by platform team activity.

Build metrics matter less than deployment metrics.
Feature counts matter less than friction reduction.

### 3. Formation Phase Has Different Metrics

During Formation (v0.1), track **surface stabilization** metrics.

Post-Formation, shift to **operational excellence** metrics.

### 4. Measurement Must Not Create Burden

Metrics should be:

- Automatically collected where possible
- Low overhead to report
- Transparent to developers
- Used to help, not to punish

---

## Formation Phase Metrics (v0.1)

Formation phase focuses on **surface stabilization**, not operational performance.

Track progress toward exit criteria: contract adoption, generator readiness, GitOps authority.

### Contract Adoption Metrics

**Purpose**: Validate that the contract becomes the dominant interface

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| % workloads with `zave.yaml` | ≥80% | Automated scan of repositories in REPO_TAXONOMY (tenant + portfolio categories) |
| % workloads with valid contract | 100% | CI validation pass rate |
| Average infrastructure decisions per workload | ≤5 | Count of required spec fields per contract |
| % workloads using shared workflows | ≥80% | GitLab/GitHub Actions workflow reference audit |

**Exit Criteria**: ≥80% of workloads deploy via contract without repo design decisions

---

### Developer Experience Standardization Metrics

**Purpose**: Validate consistent onboarding experience

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| % workloads with docker-compose | 100% (tenant + portfolio) | Automated file existence check |
| % workloads with `.env.example` | 100% (tenant + portfolio) | Automated file existence check |
| % workloads with README "Local Development" section | 100% (tenant + portfolio) | grep pattern match |
| Time to first local run (new contributor) | <5 minutes | Survey or onboarding log |

**Exit Criteria**: Every contract-governed workload follows DEVELOPER_EXPERIENCE.md standard

---

### GitOps Authority Metrics

**Purpose**: Validate GitOps as lifecycle authority

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| % deployments via GitOps | 100% | Deployment source audit |
| % workloads registered in GitOps | ≥80% | gitops repository audit |
| Manual kubectl interventions per month | <5 (break-glass only) | Audit log review |
| GitOps PR automation rate | ≥50% | Manual vs automated PR count |

**Exit Criteria**: GitOps is single lifecycle authority with no routine manual steps

---

### Generator Readiness Metrics

**Purpose**: Track progress toward automated scaffolding

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| % workloads created via generator | 0% (v0.1), 80% (post-Formation) | Repository creation audit |
| % shared workflows generated vs authored | 0% (v0.1), 80% (post-Formation) | Workflow source analysis |
| Bootstrap steps required | Manual scaffold (v0.1), 1 command (target) | Documentation audit |

**Exit Criteria**: `zave init` exists and generates repositories end-to-end

---

### POC Governance Metrics

**Purpose**: Validate exploratory work is documented and tracked

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| % POCs with README System Design template | 100% | Automated validation (POC_GOVERNANCE.md CI check) |
| % POCs with governance metadata | 100% | grep pattern match for Status/Author/Date |
| % POCs reviewed in last 6 months | 100% (Active status) | Review date metadata |
| POC graduation rate | Track trend | Count of Graduated status changes |

**Tracking**: POCs demonstrate architectural thinking and create portfolio value

---

## Operational Metrics (Post-Formation)

Once Formation exits, shift to measuring **delivery performance** and **developer productivity**.

### DORA Four Keys

**Purpose**: Measure software delivery performance

Reference: https://dora.dev/

| Metric | Elite Target | Measurement Method |
|--------|--------------|-------------------|
| **Deployment Frequency** | Multiple deploys per day | GitOps commit-to-deployment tracking |
| **Lead Time for Changes** | <1 hour | Git commit timestamp to production deployment |
| **Change Failure Rate** | <15% | Failed deployments / total deployments |
| **Mean Time to Recovery (MTTR)** | <1 hour | Incident detection to resolution time |

**Why DORA Four Keys**:
- Industry-standard benchmarks
- Proven correlation with organizational performance
- Align with platform goals (fast, safe delivery)

---

### Developer Productivity Metrics

**Purpose**: Measure actual developer efficiency

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Time to First Deploy (TTFD)** | <1 hour (new workload) | Bootstrap to first deployment timestamp |
| **Self-Service Completion Rate** | ≥85% | % tasks completed without platform team intervention |
| **Platform Support Tickets** | Track by category | Ticket system categorization: blocked / question / bug |
| **Contract-to-Deploy Cycle Time** | <15 minutes | zave.yaml commit to running deployment |

**Developer Independence** (DORA finding: 5% productivity improvement):
- % deployments requiring platform team help
- Support ticket trend (decreasing = good)
- Self-service feature adoption

---

### Developer Satisfaction Metrics

**Purpose**: Measure subjective developer experience

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Platform CSAT** | ≥4/5 | Quarterly survey: "Rate platform experience 1-5" |
| **Platform NPS** | ≥30 | Quarterly survey: "Likelihood to recommend platform" |
| **Friction Point Reports** | Track volume/category | Developer-submitted friction points via DX PM |
| **Onboarding Satisfaction** | ≥4/5 | Post-onboarding survey for new workload creators |

**Survey Cadence**: Quarterly (avoid survey fatigue)

**Sample Questions**:
- "How easy is it to deploy a new workload?" (1-5 scale)
- "How clear is platform documentation?" (1-5 scale)
- "What is the biggest friction point you experience?"
- "Would you recommend this platform to another team?" (NPS)

---

### Capability Adoption Metrics

**Purpose**: Validate platform capabilities are valuable and usable

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Capability Usage Rate** | ≥50% of workloads use ≥1 capability | Contract audit of `spec.capabilities` |
| **Top Capability Adoption** | Track by capability name | Count of workloads using each capability |
| **Capability Request Volume** | Track trend | POC submissions for new capabilities |

**Insight**: Low adoption may indicate:
- Capability is not valuable
- Capability is too complex
- Documentation is unclear

---

### Platform Efficiency Metrics

**Purpose**: Ensure platform team focuses on leverage, not toil

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Platform Team Time in Toil** | <30% | Weekly time tracking: reactive support vs proactive work |
| **Automation Coverage** | ≥80% of tasks | % tasks automated vs manual |
| **Breaking Change Frequency** | <2 per year | Contract version breaking changes |
| **Tenant-Facing API Stability** | No unversioned changes | Contract schema change audit |

**Anti-Goal**: Platform team becoming "ticket-ops" vending machine

---

## Measurement Infrastructure

### Automated Collection (Target State)

Metrics should be collected automatically where possible:

- **Contract audits**: Scheduled job scans repositories, parses `zave.yaml`, emits metrics
- **GitOps audits**: Scan gitops repository for workload registration
- **Deployment metrics**: Extract from GitOps reconciliation logs (Flux events)
- **CI metrics**: Extract from pipeline execution logs
- **File existence checks**: Scheduled scan of tenant/portfolio repositories

### Manual Collection (Formation Phase)

During Formation, some metrics require manual collection:

- Developer satisfaction surveys (quarterly Google Form or similar)
- Time to First Deploy (ask new workload creators)
- Friction point reports (submitted to DX PM)

### Dashboards

Metrics should be visible to:

- **Platform team**: Full operational dashboard
- **Tenant teams**: Public platform health dashboard (TTFD, deployment frequency, known issues)
- **Leadership**: Quarterly summary (DORA metrics, CSAT, adoption rates)

**Example Dashboard Sections**:
1. Formation Progress (% toward exit criteria)
2. Developer Experience (CSAT, NPS, TTFD)
3. Delivery Performance (DORA four keys)
4. Platform Health (uptime, support volume, toil %)

---

## Metric Review Cadence

### Weekly (Platform Team)

- Support ticket volume and categorization
- Deployment frequency trend
- Breaking changes or incidents

### Monthly (Platform Team + DX PM)

- TTFD trend
- Contract adoption %
- Friction point themes

### Quarterly (Platform Team + Leadership)

- DORA four keys
- CSAT/NPS survey results
- Formation exit criteria progress
- Roadmap prioritization based on metrics

### Annually (Strategic Review)

- Platform ROI assessment
- Multi-year trend analysis
- Benchmark against industry (DORA research, State of DevOps)

---

## Formation Phase Exit: Metric-Driven Decision

Formation phase exits when metrics validate surface stabilization:

| Exit Criterion | Measured By | Target |
|----------------|-------------|--------|
| Contract dominance | % workloads with `zave.yaml` | ≥80% |
| Developer experience consistency | % workloads with docker-compose | 100% (tenant + portfolio) |
| GitOps authority | % deployments via GitOps | 100% |
| Generator readiness | `zave init` exists and functional | Yes |
| Tenant self-service | Support tickets for onboarding | <2 per month |

**Decision Rule**: Exit Formation when ≥4 of 5 criteria met, and no criterion <50% of target.

---

## Anti-Patterns to Avoid

### Vanity Metrics

**Bad**: "We deployed 500 times this month"
**Good**: "Lead time for changes decreased from 4 hours to 45 minutes"

Track outcomes, not activity.

### Measurement Theater

**Bad**: Collecting 50 metrics no one reviews
**Good**: Tracking 10 metrics that drive platform decisions

If it doesn't inform priorities, don't measure it.

### Gaming Metrics

**Bad**: Optimizing for metric targets at expense of real goals
**Good**: Using metrics to surface problems and guide improvement

Metrics are diagnostics, not goals.

### Punishing Developers

**Bad**: "Your team has low deployment frequency, fix it"
**Good**: "Low deployment frequency may indicate platform friction. What can we improve?"

Metrics identify platform gaps, not team failures.

---

## Strategic Role

The Measurement Model converts platform management from:

**Intuition-Driven**
(we think things are working)

to

**Evidence-Driven**
(we know what's working and why)

Metrics answer critical questions:

- Is the contract actually reducing cognitive load?
- Are developers more productive with the platform than without it?
- Is GitOps faster than manual deployment?
- Is Formation progressing or stalled?

Without measurement, platform success is unfalsifiable opinion.
With measurement, platform success is demonstrable fact.

---

## Related Documentation

- **OPERATING_MODEL.md** — Formation phase definition and exit criteria
- **DEVELOPER_EXPERIENCE.md** — Standards being measured
- **ARCHITECTURAL_DOCTRINE_TIER0.md** — Principles validated by metrics
- **CONTRACT_SCHEMA.md** — Contract fields audited for adoption metrics
- **POC_GOVERNANCE.md** — POC documentation standards measured

---

## External References

- DORA Platform Engineering Capability: https://dora.dev/capabilities/platform-engineering/
- DORA Four Keys: https://dora.dev/
- State of DevOps Report: https://dora.dev/research/
- Team Topologies (cognitive load): https://teamtopologies.com/

---

## See Also

- `FRICTION_FEEDBACK.md`
- `AUDIT_PROGRAM.md`
- `DEVELOPER_EXPERIENCE_JOURNEYS.md`
- `OPERATING_MODEL.md`
