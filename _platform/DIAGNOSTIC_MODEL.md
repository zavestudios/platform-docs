# ZaveStudios — Diagnostic Model v0.1

This defines how the platform should be reasoned about during troubleshooting,
gap analysis, and operational review.

## Chapter Guide

**Purpose**

Provide the diagnostic lens for reasoning across control-plane boundaries and
for identifying operability gaps.

**Read this when**

- an incident spans multiple repositories or controllers
- you need a generic gap-analysis method rather than an app-specific checklist
- you are deciding what knowledge should become a runbook or doctrine update

**Read next**

- `RUNBOOK_METHODOLOGY.md` for capture discipline
- `EXECUTION_ENVIRONMENTS.md` for where to execute diagnostic steps
- `OPERATING_MODEL_VALIDATION.md` for structured validation of platform behavior

The objective is not to make incidents disappear.
The objective is to make the system legible enough that incidents stop consuming
time through repeated ambiguity.

---

## Core Principle

Elite platform teams make the system legible.

The expensive part of an incident is often not the final fix.
It is the repeated uncertainty about:

- which control plane owns truth
- which layer is stale
- which action causes convergence
- which state is declarative vs incidental

Strong teams reduce that ambiguity deliberately.
They do not rely on memory, intuition, or chat archaeology as the primary
operating model.

---

## Legibility As A Platform Property

Platform legibility means an operator can quickly answer:

1. what the declared source of truth is
2. what intermediate rendered state exists
3. which controller is responsible for convergence
4. what the live system is actually doing
5. what the user-visible symptom is

If those answers are slow or ambiguous, the platform has an operability gap even
if the workload eventually recovers.

Legibility is therefore a first-class platform quality, not an afterthought.

---

## Diagnostic Boundary Ladder

Every meaningful platform diagnosis should move through an explicit ladder of
boundaries.

### 1. Declared Truth

Examples:

- Git state
- Vault secret values
- Terraform configuration and state
- Cloudflare configuration
- database role and grant definitions

Questions:

- What does the authoritative system say should be true?
- Is the desired state explicit and immutable?

### 2. Rendered Truth

Examples:

- Helm values secrets
- generated manifests
- ExternalSecret outputs
- tunnel publication objects
- controller-generated resources

Questions:

- How was declared truth translated?
- Did the translation preserve intent?

### 3. Controller Truth

Examples:

- Flux `Kustomization`
- `HelmRelease`
- Helm controller status
- External Secrets status
- Terraform apply state
- Cloudflare tunnel/application state

Questions:

- Which controller is expected to act?
- Has it observed the latest truth?
- Is it reconciling successfully?

### 4. Live Runtime Truth

Examples:

- pod template and environment
- running process behavior
- VM power state
- database grants and active sessions
- DNS answers
- edge routing behavior

Questions:

- What is actually running?
- Does the live system match the controller's claimed state?

### 5. User-Visible Behavior

Examples:

- browser redirect
- login flow
- HTTP status
- API response
- readiness and health behavior

Questions:

- What symptom is visible externally?
- Which earlier boundary best explains it?

---

## What Strong Teams Do

Strong platform teams use repeatable patterns:

- keep runbooks by failure class, not only by application
- define control-plane boundaries explicitly
- capture known system weirdness before it is rediscovered under pressure
- prefer immutable references wherever possible
- maintain operational inventories for critical services
- write incident retros as structured operating artifacts
- build "truth probes" that quickly expose what each boundary currently believes

These are not optimizations.
They are the normal operating discipline required for platform scale.

---

## Gap Analysis Lens

This model should be used directly for gap analysis.

When assessing a platform service, ask:

1. **Truth clarity**
   - Is the authoritative source obvious?
   - Is desired state represented explicitly?

2. **Translation clarity**
   - Is rendered state observable?
   - Can operators compare declared vs rendered vs live without guesswork?

3. **Controller clarity**
   - Is the responsible controller obvious?
   - Are reconciliation triggers and intervals understood?

4. **Runtime clarity**
   - Can operators inspect the real running configuration quickly?
   - Are drift and stale state detectable?

5. **Boundary ownership**
   - Which repo or system owns the durable fix?
   - Which fixes are still manual?

6. **Recovery repeatability**
   - Is there a generic runbook for this failure class?
   - If not, should one exist now?

If any of these questions is hard to answer, the gap is not just technical debt.
It is an operability defect.

---

## Preferred Artifacts

To improve legibility, prefer the following artifacts:

- control-plane boundary notes
- generic runbooks by failure class
- environment-specific command bundles where needed
- incident summaries that capture manual repair steps
- inventories for critical shared services

Avoid relying on:

- private memory
- one-off shell history
- implicit controller behavior
- mutable tags and ambiguous references
- repeated ad hoc troubleshooting with no durable capture

---

## Relationship To Runbooks

This document explains **why** diagnostic artifacts are needed and how to reason
about platform gaps.

`RUNBOOK_METHODOLOGY.md` explains **when** to create runbooks and how to
structure them.

The documents are complementary:

- `DIAGNOSTIC_MODEL.md` = reasoning model and gap-analysis lens
- `RUNBOOK_METHODOLOGY.md` = capture model and runbook discipline

---

## Success Standard

The standard of success is not "no incidents."

The standard is:

- the next operator knows which boundary to inspect first
- repeated ambiguity decreases over time
- manual repairs are visible and backported
- the platform becomes easier to reason about after each incident

That is how a platform becomes operationally mature.

---

## See Also

- `CONTROL_PLANE_MODEL.md`
- `RUNBOOK_METHODOLOGY.md`
- `EXECUTION_ENVIRONMENTS.md`
- `OPERATING_MODEL_VALIDATION.md`
