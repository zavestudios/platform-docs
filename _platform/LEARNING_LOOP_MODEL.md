# ZaveStudios — Learning Loop Model v0.1

This document defines the autonomous retrospective loop that reviews platform
operations sessions and surfaces refinement proposals.

## Chapter Guide

**Purpose**

Define the loop structure, methodology spec, output tiers, runtime, and failure
modes for the nightly learning loop.

**Read this when**

- you are configuring or tuning the nightly loop
- a loop run produces unexpected output
- you are deciding whether a pattern belongs in auto-apply or human-review tier
- you are extending the loop's search patterns

**Read next**

- `DIAGNOSTIC_MODEL.md` for the gap-analysis lens that informs what the loop looks for
- `RUNBOOK_METHODOLOGY.md` for how findings should be captured as runbooks
- `OPERATING_MODEL.md` for platform maturity expectations

---

## Purpose

Platform knowledge accumulates unevenly. Patterns that should have been caught
earlier — deploy-time discoveries that CI could have surfaced, fixes applied
one-by-one that could have been generalized, manual steps that recur without
automation — are currently captured ad-hoc when a human notices them.

The learning loop formalizes the retrospective. Every session becomes a source
of refinement proposals. The platform gets smarter overnight without requiring
the operator to write postmortems.

The structural analog is Karpathy's autoresearch method: a propose → apply →
evaluate → keep/rollback loop driven by a plain-English methodology spec. The
metric there is validation loss. The equivalent here is: does this reduce future
troubleshooting time or improve platform predictability?

---

## Loop Structure

The loop runs as a nightly Claude Code cron job. Each run executes four phases:

### 1. Input

Read session transcripts from the current project's `.jsonl` files:

```
~/.claude/projects/-Users-xavierlopez-Dev/*.jsonl
```

Scope to transcripts from the prior 24 hours unless performing a backfill run.

### 2. Analyze

Apply the methodology spec (see below) to identify patterns across transcripts.
Each pattern match produces a candidate proposal with a classification and
confidence signal.

### 3. Propose

For each candidate, produce a structured proposal:

```
pattern:     what was observed and how many times
class:       [repeated-fix | redundant-command | deploy-surprise | manual-step | control-plane]
proposal:    what change would address the root cause
output-tier: [auto-apply | queue-for-review]
rationale:   why this is worth addressing now
```

Discard candidates that are too narrow (one-off errors), too ambiguous (no
clear remediation), or outside the defined search patterns.

### 4. Apply or Queue

Apply auto-apply tier proposals immediately.
Queue review-tier proposals as GitHub issues on the appropriate repository.
Do not apply review-tier proposals without human approval.

---

## Methodology Spec

The methodology spec defines what the loop looks for, what it must not touch,
and how to evaluate a proposal.

### What to look for

**Repeated fixes applied one-by-one that could be generalized**

A fix applied to one service that should also apply to others. A configuration
pattern corrected manually on three occasions that suggests a default is wrong.
A probe value adjusted repeatedly across different components.

**Redundant agent commands that waste tokens**

Commands the agent issues repeatedly within a session that could be replaced
by a single lookup, a cached value, or a helper. Patterns like re-reading the
same file multiple times, re-fetching the same secret path, or issuing
sequential read commands that could be parallelized.

**Deploy-time discoveries that should have been caught in CI**

Errors surfaced during `flux reconcile` or Helm upgrade that a schema
validation, lint pass, or policy check would have caught earlier. Any pattern
of the form: "we only found out at apply time that X was wrong."

**Manual steps without an automation path**

Steps labeled "Requires cluster access:" that occur in more than one session
on the same topic. Manual Vault writes that follow a predictable pattern.
Repeated copy-paste command sequences.

**Control plane improvements**

Predictability gaps: behavior that surprised the operator but is deterministic
and documentable. Readability gaps: resource names, namespace choices, or
label conventions that required clarification. Logical consistency gaps:
decisions made differently in two places that should be uniform.

### What not to touch autonomously

- Any file in `gitops/` (Flux-managed; requires PR and human approval)
- Any CI workflow or policy file
- Any Kyverno policy
- Any Terraform resource
- Any Vault secret or ExternalSecret
- Any file that would affect running cluster state

The loop is an observer and proposer. It does not apply infrastructure changes.

### How to evaluate a proposal

A proposal is worth keeping if it satisfies all three:

1. **Recurrence**: the pattern appeared in at least two sessions, or the single
   occurrence is a class of problem known to recur (deploy-surprise,
   missing-runbook)
2. **Actionability**: there is a concrete change that addresses the root cause,
   not just the symptom
3. **Proportionality**: the cost of the change is less than the cost of the
   next recurrence

Discard proposals that are observations without remediation, noise from
one-time errors, or changes whose scope exceeds what a human would approve
without investigation.

---

## Output Tiers

### Auto-apply

The loop may apply these without human review:

- **Memory entries**: new entries in `~/.claude/projects/-Users-xavierlopez-Dev/memory/`
  following the established feedback, project, user, and reference schema
- **Updates to existing memory entries**: corrections to stale or inaccurate
  memory content

### Queue for human review

The loop opens GitHub issues for these but does not apply them:

- **platform-docs issues**: doctrine gaps, missing runbooks, model updates
- **gitops issues**: HelmRelease tuning, ExternalSecret additions, resource
  changes that should go through PR review
- **platform-pipelines issues**: CI additions, lint or validation improvements

Issue body must include the `pattern`, `proposal`, and `rationale` fields from
the proposal structure above. Label with `learning-loop` so they are
distinguishable from human-authored issues.

### Never

- Do not open issues against employer or external repositories
- Do not commit or push to any repository
- Do not modify CI workflows, policies, or Terraform
- Do not send external communications

---

## Runtime

The loop runs as a Claude Code cron job registered via `CronCreate`.

**Schedule**: nightly, after sessions are expected to have ended

**Prompt file**: `~/.claude/projects/-Users-xavierlopez-Dev/learning-loop/program.md`

The prompt file is the methodology spec in executable form. It instructs the
agent on scope, search patterns, output format, and apply/queue rules. It is
the only file the loop is permitted to follow autonomously; changes to the loop
behavior go through this file, not through cron reconfiguration.

**Idempotency**: the loop reads transcripts that have already been processed
by checking a watermark in memory (`reference` type, key `learning-loop-watermark`).
On each run, it advances the watermark to the latest processed transcript
timestamp.

---

## Memory Integration

Findings feed directly into the agent memory system.

Auto-applied memory entries follow the type schema:

- `feedback`: behavioral corrections or confirmations extracted from session patterns
- `project`: updated project state, deferred items, or active blockers
- `reference`: pointers to external systems discovered during sessions

The loop does not create `user` type entries autonomously. User profile updates
require human observation.

Every auto-applied memory write is logged to a run summary file:

```
~/.claude/projects/-Users-xavierlopez-Dev/learning-loop/runs/<date>.md
```

The run summary records: transcripts scanned, proposals generated, proposals
applied, proposals queued, proposals discarded.

---

## Failure Modes

**The loop produces mostly noise**

The methodology spec is too permissive. Raise the recurrence threshold in the
spec from two sessions to three, or add a confidence floor that requires the
pattern to appear in at least two distinct problem areas.

**The loop misses obvious patterns**

The search pattern definitions are too narrow. Add the missed class as an
explicit search pattern in `program.md` with examples drawn from the sessions
that prompted the update.

**The loop opens too many issues**

The queue-for-review tier is too eager. Add a proportionality filter: only
queue issues for patterns where the cost of recurrence is above a threshold
(estimated operator time > 15 minutes).

**The loop applies a bad memory entry**

Correct the entry manually. Add a note to `program.md` excluding that class of
inference. The watermark ensures the loop does not reprocess the same
transcripts.

**The loop stalls or produces no output**

Check whether new `.jsonl` files exist beyond the watermark. Verify the cron
prompt file exists and is well-formed. Run manually with a one-day lookback to
validate the loop is functional before the next nightly run.

---

## Relationship To Other Models

This model is the retrospective layer that feeds improvements back into the
platform's operating artifacts. It does not replace:

- `DIAGNOSTIC_MODEL.md` — the reasoning model for active incidents
- `RUNBOOK_METHODOLOGY.md` — the discipline for capturing runbooks during incidents
- `OPERATING_MODEL_VALIDATION.md` — structured audits of platform behavior

The loop supplements these by surfacing patterns that occur across sessions,
not within a single incident.

---

## Success Standard

The loop is working when:

- the same manual step does not appear in three consecutive sessions without
  a queued proposal to automate or document it
- memory entries stay current without requiring explicit human updates after
  every session
- deploy-time surprises decrease as CI catches more classes of error over time

The loop is not working when:

- queued issues go unreviewed and accumulate without affecting behavior
- the operator cannot tell what the loop did on a given night
- the loop applies memory entries that contradict current platform state

---

## See Also

- `DIAGNOSTIC_MODEL.md`
- `RUNBOOK_METHODOLOGY.md`
- `OPERATING_MODEL.md`
- `MEASUREMENT_MODEL.md`
