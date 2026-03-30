# ZaveStudios — Runbook Methodology v0.1

This defines when runbooks should be created, what they should contain, and how
incident knowledge should be captured before it is forgotten.

## Chapter Guide

**Purpose**

Define how troubleshooting knowledge is captured, promoted, and turned into
reusable operating artifacts.

**Read this when**

- a session has become expensive enough that its lessons should not be lost
- you need to decide whether something belongs in a local note, a runbook, or
  platform doctrine
- you are standardizing how agents and humans preserve diagnostic history

**Read next**

- `DIAGNOSTIC_MODEL.md` for the reasoning model that runbooks should encode
- `EXECUTION_ENVIRONMENTS.md` for where platform actions are expected to run
- `PR_WORKFLOW.md` for how durable follow-up changes should land

The goal is not to predict every incident in advance.
The goal is to make expensive troubleshooting sessions produce reusable operating
knowledge.

---

## Why Runbooks Exist

Runbooks are not application-specific by default.
They exist to make platform control planes legible.

The common failure pattern is not usually "application X is broken."
It is:

- the source of truth is unclear
- multiple control planes are involved
- operators repeat the same checks in the same order
- manual recovery steps are discovered but not captured
- the same ambiguity returns in the next session

Runbooks are the mechanism for converting one expensive incident into faster
future diagnosis.

---

## Platform-First Scope

Preferred runbooks are **generic by failure class**, not one document per app.

Examples:

- desired-state vs live-state debugging
- Flux / Helm reconciliation debugging
- rendered-config debugging
- edge exposure / DNS / tunnel debugging
- external dependency debugging
- stateful workload recovery

Application-specific notes should appear only when:

- the application has unique invariants that do not generalize
- the generic runbook is insufficient without product-specific behavior
- the application is itself a platform-defining control plane

Default posture:

- generic runbook first
- application example second

---

## Control Plane Boundary Principle

Every runbook must be written across explicit control plane boundaries.

At minimum, a troubleshooting path should distinguish:

1. **Declared source of truth**
   - Git
   - Vault
   - Terraform state
   - Cloudflare configuration
   - database state

2. **Rendered or translated state**
   - Helm values secrets
   - generated manifests
   - ExternalSecret outputs
   - controller-owned intermediate objects

3. **Controller state**
   - Flux Kustomization / HelmRelease
   - Helm controller status
   - External Secrets status
   - tunnel/controller status

4. **Live runtime state**
   - pod template
   - process environment
   - VM state
   - database grants
   - DNS answers

5. **External user-visible behavior**
   - browser response
   - API response
   - redirect behavior
   - login path

Good runbooks move through those boundaries deliberately.
They do not jump directly from symptom to random mitigation.

---

## When To Create A Runbook

Do not wait until the start of a session to know a runbook will be needed.

Create or update a runbook when any of these are true:

- the same confusion has appeared more than once
- the session crosses three or more control planes
- the recovery takes more than 30–60 minutes
- the issue requires manual repair outside normal Git reconciliation
- the final root cause was not obvious from the initial symptom
- the team had to rediscover the same sequence of checks

If those triggers are met, the incident is runbook-worthy even if no document
existed when the session began.

---

## Incident Capture Method

During a live troubleshooting session, do **not** try to author a polished
runbook in real time.

Instead, maintain a lightweight scratch incident log.

The conversation itself may serve as that scratch log if it contains:

- the observed symptom
- the current boundary being inspected
- the commands or checks performed
- the result
- the conclusion drawn
- the next boundary to inspect

This scratch log is temporary working memory, not the final artifact.

After the incident, convert only the durable lessons into:

- a generic runbook
- a control-plane note
- code or configuration changes
- a short incident summary if manual recovery occurred

---

## Minimum Runbook Structure

A runbook should stay short and decisive.

Required sections:

1. **Symptom**
   - what the operator sees first

2. **Boundary Ladder**
   - ordered checks from source of truth to live behavior

3. **Commands or Checks**
   - exact commands where appropriate
   - expected outputs or interpretations

4. **Decision Points**
   - what result means
   - what next branch to follow

5. **Recovery Actions**
   - declarative fix if one exists
   - break-glass action if required
   - backport requirement if break-glass was used

6. **Escalation / Ownership**
   - which repo or control plane owns the durable fix

Runbooks should avoid narrative prose.
They should optimize for high-signal operator use under pressure.

---

## Relationship To Repository Ownership

Runbook location depends on scope:

- `platform-docs`
  - methodology
  - generic control-plane and debugging guidance
  - reusable operating patterns

- environment or implementation repos such as `gitops`
  - concrete command sequences
  - environment-specific controller paths
  - platform-instance-specific edge, DNS, or dependency details

Promotion rule:

- start local when the knowledge is environment-specific
- promote to `platform-docs` when the lesson changes platform-wide operating
  practice

---

## Desired Outcome

Elite platform teams do not eliminate incidents.
They eliminate repeated ambiguity.

The standard of success is:

- the next operator knows which boundary to inspect first
- the team stops repeating the same failed guesses
- manual repairs are visible and backported
- control planes become more explicit over time

---

## See Also

- `DIAGNOSTIC_MODEL.md`
- `CONTROL_PLANE_MODEL.md`
- `EXECUTION_ENVIRONMENTS.md`
- `PR_WORKFLOW.md`
