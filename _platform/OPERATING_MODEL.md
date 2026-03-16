# ZaveStudios — Platform Operating Model v0.1.5 (Formation Phase)

## Phase Definition

ZaveStudios is currently in **Platform Formation**, not Platform Operation.

This implies:

- Contracts exist but are not yet the dominant interface  
- Repositories still encode architectural decisions  
- Delivery strategies are evolving  
- GitOps is the intended lifecycle authority, with explicit temporary exceptions  
- Automation assists humans rather than replacing decisions  

This is expected for an emerging internal developer platform.

Canonical contract reference:

- All contract examples in this document follow
  `CONTRACT_SCHEMA.md` → `Canonical Workload Contract Definition`.

---

## Formation Goals

The purpose of this phase is **surface stabilization**, not feature expansion.

The platform must converge on:

1. A frozen workload contract schema  
2. A fixed, enumerated set of delivery strategies  
3. A stable repository taxonomy with machine-readable semantics  
4. A GitOps repository representing full platform state  
5. A bootstrap path requiring minimal architectural reasoning  

Until these stabilize, new capability growth should be constrained.

## Implemented vs Target Features

| Capability | Formation v0.1 (Implemented) | Target State |
| --- | --- | --- |
| Canonical contract shape | Yes (`apiVersion/kind/metadata/spec`) | Stable across versions |
| Runtime support | `container`, `static` | Managed runtime families (`node/python/go/java`) |
| Build mode | `dockerfile` | Additional managed build modes |
| Delivery strategies | `rolling` | `recreate`, `blue-green`, `canary` |
| Bootstrap command | Template/manual scaffolding | `zave init <workload-type>` |
| GitOps authority | GitOps-first + explicit exceptions | Full lifecycle authority with no routine manual steps |

---

## Exit Criteria from Formation Phase

ZaveStudios exits Formation when:

- ≥80% of workloads deploy via the contract without repo design decisions  
- Pipelines are generated rather than authored manually  
- GitOps becomes the single lifecycle authority  
- Tenant onboarding requires no platform expert intervention  

Only after these conditions hold should capability expansion accelerate.

---

# Contract-First Bootstrap Specification

## Workload Input Surface

A workload (tenant or portfolio) must be expressible using a minimal declarative contract.

Example:

```yaml
apiVersion: zave.io/v1
kind: Workload
metadata:
  name: payments-api
spec:
  runtime: container
  exposure: public-http
  delivery: rolling
```

This Workload Contract object is the only required platform interface for deployable workloads.
The conventional filename is `zave.yaml`.

Workload repositories should not define:

- pipelines
- infrastructure topology
- networking rules
- cluster overlays
- security mechanics  

All of those are platform responsibilities.

---

## Platform Responsibilities Triggered Automatically

Target state (not yet fully implemented in Formation):

From the contract, the platform must deterministically generate:

1. Repository scaffold aligned to taxonomy  
2. CI pipeline bound to shared platform workflows  
3. Image build configuration  
4. Deployment strategy binding  
5. GitOps registration pull request  
6. DNS and ingress configuration  
7. Baseline observability wiring  
8. Policy and security controls  

The workload repository declares intent.  
The platform materializes execution.

---

## Bootstrap Command Target State

Target state (not yet implemented):

The ideal bootstrap experience should collapse to a single command:

```bash
zave init http-service
```

This should:

- Generate the contract file  
- Create the repository  
- Bind platform workflows  
- Register the workload in GitOps  
- Produce a deployable system without further infrastructure decisions  

If additional manual decisions are required, the platform surface is still too large.

Formation roadmap hook:

- Until `zave init` exists, onboarding may use templates and manual PR scaffolding.
- Any manual bootstrap step must map to a future generator behavior.

Portfolio workload migration hook:

- External-facing repositories (for example Hugo/Jekyll sites) are not governance exceptions.
- These workloads should migrate to contract-backed delivery (`spec.runtime: static`) and GitOps registration.
- Until migration completes, gaps must be tracked explicitly as Formation conformance debt.

---

# Platform Control Plane

For details on authority layers and control flow, see **CONTROL_PLANE_MODEL.md**.

Formation delivery semantics:

- `spec.delivery` is contract-declared.
- In Formation (`v0.1`), only `rolling` is implemented end-to-end.
- `recreate`, `blue-green`, and `canary` are reserved until lifecycle support is complete.

---

# Platform Roles and Responsibilities

## Developer Experience Ownership

The platform requires an explicit **Developer Experience (DX) Owner** role.

This role is responsible for:

- **Mapping critical user journeys** across the platform
- **Identifying and prioritizing friction points** reported by tenant teams
- **Advocating for tenant needs** in platform architectural decisions
- **Tracking developer satisfaction metrics** (CSAT, NPS, friction reports)
- **Coordinating onboarding improvements** and documentation clarity
- **Serving as primary tenant-facing contact** for platform questions

**Formation Phase Responsibility:**

During Formation, the DX Owner focuses on:

- Validating exit criteria are actually improving developer experience
- Collecting feedback on contract model usability
- Identifying documentation gaps
- Tracking Time to First Deploy and onboarding friction

**Post-Formation Responsibility:**

After Formation, the DX Owner focuses on:

- Continuous measurement of DORA metrics and satisfaction
- User journey optimization
- Capability prioritization based on tenant requests
- Platform roadmap input driven by actual developer needs

**Why This Role Matters (DORA Finding):**

Research shows platforms without dedicated DX ownership tend toward:

- "Ivory tower" syndrome: dictating standards without collaboration
- "Ticket-ops" vending machine: reactive support with no proactive improvement
- Optimizing for platform team convenience instead of tenant productivity

The DX Owner ensures the platform serves tenant needs, not platform team preferences.

**Measurement Responsibility:**

See **MEASUREMENT_MODEL.md** for metrics this role tracks and reports.

---

# Platform-Tenant Collaboration Model

The platform must avoid two failure modes:

1. **Ivory Tower Syndrome**: Platform team dictates standards without tenant input or collaboration
2. **Ticket-Ops Vending Machine**: Platform team operates purely reactively, never building leverage

ZaveStudios achieves balance through **bounded autonomy** and **structured collaboration**.

---

## Authority Boundaries

### Platform Owns (Non-Negotiable)

The platform team has exclusive authority over:

- **Contract schema evolution**: What fields exist in `zave.yaml` and their semantics
- **Delivery strategy implementation**: How `rolling`, `blue-green`, `canary` actually work
- **GitOps infrastructure**: How reconciliation happens, what tools are used
- **Generator logic**: How `zave init` creates repositories
- **Shared workflow mechanics**: How CI pipelines validate and build
- **Infrastructure topology**: Network policy, ingress rules, cluster configuration
- **Capability module implementation**: How reusable capabilities are built

**Rationale**: These are architectural invariants that prevent variance and maintain platform integrity.

Tenants do not vote on these mechanics.

---

### Tenants Own (Autonomous)

Tenant teams have exclusive authority over:

- **Application architecture**: Language, framework, internal code structure
- **Business logic**: Domain models, API contracts, feature implementation
- **Runtime configuration**: Environment variables, feature flags, resource sizing (within policy bounds)
- **Data models**: Database schemas, migrations, query patterns
- **Testing strategies**: Unit tests, integration tests, test frameworks
- **Local development workflows**: IDE choice, debugging tools, local extensions

**Rationale**: These are workload-specific decisions the platform should not constrain.

Platform does not dictate application design.

---

### Shared Decisions (Collaborative)

Some decisions require platform-tenant collaboration:

| Decision | Platform Contribution | Tenant Contribution | Resolution Mechanism |
|----------|----------------------|---------------------|---------------------|
| **New capability request** | Feasibility assessment, implementation | Use case definition, demand validation | POC → DX PM review → graduation |
| **Contract schema extension** | Breaking change analysis, versioning strategy | Required fields, use case | RFC process with tenant feedback |
| **Delivery strategy selection** | Available options, trade-offs | Workload requirements | Tenant chooses from platform-provided options |
| **Resource policy bounds** | Cost controls, cluster capacity | Workload performance needs | Tiered resource model with opt-in sizing |
| **Observability requirements** | Standard capabilities, integration | Custom metrics, alerts | Standard baseline + capability extensions |

**Resolution Principle**: Platform provides options, tenants choose from menu.

Platform does not create one-size-fits-all solutions ignoring workload diversity.

---

## Collaboration Mechanisms

### 1. Friction Point Reporting (Tenant → Platform)

Tenants submit friction points to the DX PM:

- **What**: "Adding a database requires 30 minutes of docker-compose edits"
- **Impact**: "Slows every workload onboarding"
- **Suggestion**: "Generator should create docker-compose from contract"

**Platform Response**:
- Acknowledge receipt
- Categorize: quick fix / roadmap item / known limitation
- Track in backlog with tenant demand count
- Report resolution in changelog

**Anti-Pattern**: Friction points submitted via ad-hoc Slack DMs and forgotten.

---

### 2. Capability Requests (Tenant → Platform)

Tenants propose new reusable capabilities via POC process:

1. **POC Creation**: Tenant builds prototype in POC repository following POC_GOVERNANCE.md
2. **System Design Doc**: Document alternatives, trade-offs, recommendation
3. **DX PM Review**: Assess demand (is this a common need?), feasibility, ROI
4. **Platform Decision**: Approve for graduation / Defer / Reject with rationale
5. **Implementation**: If approved, platform team builds as platform-service
6. **Availability**: Capability added to registry, tenants adopt via contract

**Example Flow**:
- Tenant: "We need Redis caching"
- POC: Build Redis integration prototype
- DX PM: "3 other teams also requested Redis"
- Platform: Approve, implement as `redis` persistence engine
- Result: All tenants can now use `persistence: engine: redis`

**Anti-Pattern**: Platform team guesses what capabilities tenants need without validation.

---

### 3. Contract Evolution (Platform → Tenant)

When the platform proposes contract schema changes:

1. **RFC Draft**: Platform writes proposal with rationale, examples, migration path
2. **Tenant Feedback Period**: 2-week review, tenants comment on feasibility/impact
3. **Revision**: Platform incorporates feedback, addresses breaking change concerns
4. **Versioning**: New contract version published with upgrade tooling
5. **Migration Window**: Tenants have ≥6 months to migrate before old version sunsets

**Example**:
- Platform: "We propose adding `spec.autoscaling` for HPA support"
- Tenants: "Need `minReplicas` and `maxReplicas` as separate fields, not single `replicas`"
- Platform: Revises schema, releases v2 with migration tool
- Tenants: Upgrade via `zave contract migrate v1 → v2`

**Anti-Pattern**: Platform drops breaking changes without migration path or feedback window.

---

### 4. Roadmap Prioritization (Collaborative)

Platform roadmap balances:

- **Tenant-driven demand**: Friction points, capability requests, survey results
- **Platform-driven leverage**: Automation, generator, GitOps maturity
- **Strategic alignment**: Formation exit criteria, DORA metrics improvement

**Quarterly Roadmap Process**:

1. **DX PM aggregates** tenant friction points and capability requests
2. **Platform team proposes** leverage initiatives (generator, automation)
3. **Joint review**: Prioritize based on:
   - Tenant pain level (CSAT, friction report volume)
   - Platform leverage (how many workloads benefit?)
   - Strategic goals (Formation exit criteria)
4. **Publish roadmap** with rationale for included/excluded items

**Anti-Pattern**: Platform builds features no one asked for while ignoring high-pain friction points.

---

### 5. Office Hours / Open Forum (Recurring)

**Weekly Platform Office Hours**:
- Tenants can ask questions, discuss patterns, propose ideas
- Platform team provides guidance, clarifies documentation
- Informal feedback collection

**Monthly DX Review**:
- DX PM presents friction point themes
- Platform team shares progress on initiatives
- Tenants provide input on priorities

**Anti-Pattern**: Platform team operates in isolation without regular tenant interaction.

---

## Anti-Patterns to Avoid

### Ivory Tower (Platform Dictates)

**Symptom**: "We built this new deployment strategy, all tenants must migrate by Friday"

**Problem**:
- No tenant input on requirements
- No migration path or tooling
- No feedback period
- Breaking change forced without justification

**Prevention**:
- Contract changes require RFC process with feedback period
- Breaking changes require migration tooling and long windows
- DX PM ensures tenant needs drive platform decisions

---

### Ticket-Ops Vending Machine (Platform Reacts)

**Symptom**: "Submit a ticket and we'll manually deploy it for you"

**Problem**:
- No leverage (platform team becomes bottleneck)
- No self-service (tenants blocked on platform team)
- No automation (repeated manual work)

**Prevention**:
- Platform builds automation instead of doing manual work repeatedly
- Tickets should trigger "how can we make this self-service?" not "how can we do this for them?"
- Measure platform team toil % (target: <30%)

---

### Ignoring Diversity (One-Size-Fits-All)

**Symptom**: "All workloads must use exactly the same runtime configuration"

**Problem**:
- Workloads have different needs (API vs batch job vs static site)
- Forcing uniformity creates artificial constraints
- Tenants work around platform instead of using it

**Prevention**:
- Contract allows bounded variance (`spec.runtime`, `spec.delivery`, `spec.exposure`)
- Resource tiers provide flexibility within policy
- Capability modules let tenants opt-in to extensions

---

## Escalation Path

When platform-tenant disagreement arises:

1. **DX PM facilitates** discussion, clarifies requirements
2. **Platform team explains** architectural constraints, trade-offs
3. **Tenant team explains** business requirements, impact
4. **Collaborative resolution**:
   - Can tenant need be met within existing contract? (platform guides)
   - Can contract be extended without breaking invariants? (RFC process)
   - Is this a POC-worthy experiment? (prototype first)
   - Is this truly incompatible with platform model? (escalate to leadership)

**Last Resort**: Leadership decides, but this should be rare if collaboration mechanisms work.

---

## Strategic Role

The Collaboration Model converts platform-tenant interaction from:

**Adversarial**
(platform blocks tenants, tenants bypass platform)

to

**Symbiotic**
(platform enables tenants, tenants inform platform)

Successful collaboration requires:

- **Clear boundaries**: What platform owns vs what tenants own
- **Structured channels**: Friction reports, POC graduation, RFC process
- **Explicit prioritization**: Roadmap driven by evidence, not politics
- **Mutual respect**: Platform team values tenant feedback, tenants value platform expertise

When collaboration works:

- Tenants trust the platform to solve common problems
- Platform team focuses on high-leverage work, not toil
- The constrained path is genuinely the fastest path
- Friction points convert into automation improvements

---

## Related Documentation

- **MEASUREMENT_MODEL.md** — Metrics for tracking platform-tenant collaboration health
- **POC_GOVERNANCE.md** — Structured process for capability requests
- **CONTRACT_SCHEMA.md** — Bounded autonomy within contract fields
- **DEVELOPER_EXPERIENCE.md** — User journeys that collaboration must optimize

---

# Strategic Interpretation

ZaveStudios is transitioning from:

**Architecture Platform**
(where experts design systems repeatedly)

to

**Product Platform**
(where workloads are instantiated through a constrained interface)

The Formation Phase exists to stabilize that transition.

Success depends less on adding features and more on:

- shrinking the decision surface
- freezing the contract
- encoding repository semantics
- elevating GitOps to lifecycle authority
- ensuring the reference path is always the fastest path  
