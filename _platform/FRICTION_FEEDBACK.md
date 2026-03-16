# ZaveStudios — Friction Point Feedback Mechanism v0.1

This document defines the process for collecting, triaging, and resolving developer friction points.

It exists to close the loop: **tenant pain → platform improvement**.

Without a structured feedback mechanism, friction points are:

- Lost in ad-hoc Slack DMs
- Forgotten after discussion
- Never prioritized against roadmap
- Invisible to platform metrics

With structured feedback, friction points become:

- Visible and trackable
- Prioritized by demand and impact
- Converted into actionable roadmap items
- Measured for resolution time

---

## Purpose

The friction feedback mechanism enables:

1. **Systematic capture** of developer pain points
2. **Evidence-based prioritization** (which friction affects most people?)
3. **Transparent resolution tracking** (what's being worked on?)
4. **Measurable improvement** (friction volume decreasing over time)

This directly supports DORA platform engineering principles:

- Clear feedback on task outcomes (most important DX capability)
- Developer independence (reduce need for platform team assistance)
- Continuous improvement based on user research, not assumptions

---

## Friction Point Definition

A **friction point** is any unnecessary difficulty in:

- Bootstrapping new workloads
- Local development setup
- Deploying code changes
- Adding platform capabilities
- Debugging production issues
- Understanding platform documentation

**Friction is NOT**:
- Inherent complexity (e.g., "distributed systems are hard")
- Security/governance requirements (e.g., "need approval for prod deploy")
- Learning curve for new technologies (e.g., "learning Kubernetes")

**Friction IS**:
- Manual work that could be automated
- Repetitive steps across workloads
- Documentation gaps causing confusion
- Slow feedback loops
- Inconsistent behavior across workloads

**Example Friction Points**:
- ✅ "Adding a database requires 30 minutes of manual docker-compose edits"
- ✅ "I can't tell if my deployment succeeded without asking platform team"
- ✅ "Every workload repo has different local setup instructions"
- ❌ "Kubernetes networking is complex" (inherent complexity, not platform friction)
- ❌ "I have to wait for PR review before deploying" (intentional governance)

---

## Submission Channels

### Primary Channel: GitHub Discussions (Recommended)

**Location**: `platform-docs` repository → Discussions tab → "Friction Points" category

**Why GitHub Discussions**:
- Visible to all tenant teams (avoid duplicate reports)
- Searchable and linkable
- Allows voting/reactions (measure demand)
- Can be converted to Issues when actionable
- Preserves history and context

**How to Submit**:

1. Navigate to: https://github.com/zavestudios/platform-docs/discussions
2. Click "New discussion"
3. Select category: "Friction Points"
4. Fill out template (see below)
5. Submit

**Template**:

```markdown
### What task were you trying to accomplish?
[e.g., "Add PostgreSQL to an existing workload"]

### What friction did you encounter?
[e.g., "Had to manually update docker-compose.yml with 20+ lines of config"]

### How much time did this friction cost?
[e.g., "30 minutes" or "Blocked for 2 hours waiting for platform team"]

### How often does this happen?
[e.g., "Every time I add a database" or "One-time during initial setup"]

### What would eliminate this friction?
[Optional - your suggestion]
[e.g., "Generator could create docker-compose from contract automatically"]

### Related Documentation
[Links to docs you were following, if any]
```

---

### Alternative Channel: Direct to DX PM

**When to Use**:
- Sensitive/confidential friction (e.g., team dynamics)
- Quick informal feedback
- Urgent blockers needing immediate attention

**How**: Email, Slack DM, or office hours

**DX PM Responsibility**: Convert to GitHub Discussion (anonymized if needed) for tracking

---

## Triage Process

**Frequency**: Weekly (DX PM reviews all new friction point submissions)

**Triage Steps**:

1. **Categorize by type**:
   - Automation gap (manual work that could be automated)
   - Documentation gap (unclear or missing docs)
   - Platform bug (something broken)
   - Feature request (new capability needed)
   - User error (misunderstanding, not actual friction)

2. **Assess impact**:
   - **High**: Blocks multiple teams frequently
   - **Medium**: Affects single team frequently, or multiple teams occasionally
   - **Low**: Rare occurrence, workaround exists

3. **Measure demand**:
   - Count upvotes/reactions on GitHub Discussion
   - Track duplicate reports (multiple teams hit same friction)

4. **Assign resolution category**:
   - **Quick fix**: Can be resolved in <1 day (documentation update, script, etc.)
   - **Roadmap item**: Requires engineering work (generator feature, automation, etc.)
   - **Known limitation**: Platform constraint, cannot fix in Formation phase
   - **Won't fix**: Not actually platform friction (inherent complexity, intentional governance)

5. **Label and respond**:
   - Add GitHub label: `friction: automation`, `friction: docs`, `friction: bug`, `friction: capability`
   - Add impact label: `impact: high`, `impact: medium`, `impact: low`
   - Add status label: `status: triaged`, `status: in-progress`, `status: resolved`, `status: wont-fix`
   - Comment with triage decision and next steps

---

## Resolution Workflow

### Quick Fixes (<1 day)

**Examples**:
- Update documentation with missing steps
- Add clarifying comments to example files
- Create helper script for common task
- Update README templates

**Process**:
1. DX PM or platform team member creates PR
2. Link PR in GitHub Discussion
3. Merge PR
4. Comment on Discussion: "Resolved in PR #123"
5. Close Discussion with "Resolved" label
6. Add to changelog: "Fixed friction: [description]"

**Target Resolution Time**: <1 week from triage

---

### Roadmap Items (Engineering Work Required)

**Examples**:
- Generator automation (e.g., "Auto-create docker-compose from contract")
- CI/CD improvements (e.g., "Add deployment status notifications")
- Capability additions (e.g., "Support Redis persistence engine")

**Process**:
1. DX PM converts Discussion to GitHub Issue in relevant repository
2. Add to platform roadmap backlog
3. Prioritize based on:
   - Impact (high/medium/low)
   - Demand (# of upvotes, duplicate reports)
   - Strategic alignment (Formation exit criteria)
   - Effort estimate (quick wins vs long projects)
4. Comment on Discussion with roadmap decision:
   - "Added to roadmap for [timeframe]" or
   - "Deferred until post-Formation due to [reason]"
5. Link Issue to Discussion for tracking
6. When implemented, close Discussion with "Resolved" label

**Target Resolution Time**: Variable (prioritized quarterly)

---

### Known Limitations

**Examples**:
- "Cannot use kubectl directly" (architectural invariant, GitOps-only)
- "Generator doesn't exist yet" (Formation phase gap, target state documented)
- "Must wait for managed database provisioning" (external dependency)

**Process**:
1. Comment on Discussion explaining limitation and rationale
2. Add label: `status: known-limitation`
3. Document workaround if available
4. Keep Discussion open for visibility
5. If limitation will be resolved post-Formation, note timeline

**Transparency**: Known limitations should be publicly visible, not hidden

---

### Won't Fix

**Examples**:
- "I don't like Kubernetes" (platform choice, not friction)
- "I want full kubectl access" (violates architectural invariants)
- "I need custom pipeline YAML" (violates contract model)

**Process**:
1. Comment explaining why this is not platform friction
2. Add label: `status: wont-fix`
3. Provide context on architectural rationale
4. Suggest alternative if possible
5. Close Discussion

**Transparency**: Respectfully explain constraints, don't dismiss

---

## Monthly Review (Platform Team + DX PM)

**When**: First week of each month

**Agenda**:

1. **Friction trends**:
   - Total new friction points submitted this month
   - Breakdown by category (automation / docs / bug / capability)
   - Breakdown by impact (high / medium / low)
   - Resolution rate (% closed vs opened)

2. **High-impact unresolved friction**:
   - What's blocking teams most?
   - Do we need to re-prioritize roadmap?

3. **Quick win opportunities**:
   - Are there clusters of friction that could be batch-resolved?
   - Documentation themes that need addressing?

4. **Roadmap impact**:
   - Should any friction points move up in priority?
   - Should any roadmap items be de-prioritized?

5. **Metrics update**:
   - Update MEASUREMENT_MODEL.md friction point volume tracking
   - Trend analysis: is friction decreasing over time?

**Output**: Updated roadmap priorities, changelog of resolved friction

---

## Quarterly Summary (Public)

**When**: End of each quarter

**Audience**: All tenant teams

**Content**:

```markdown
# Platform Friction Report - Q[X] 20XX

## Summary

- **Friction points submitted**: [count]
- **Friction points resolved**: [count]
- **Resolution rate**: [%]
- **Average resolution time**: [days]

## Top Friction Points Resolved

1. [Description] - Resolved by [PR/Issue link]
2. [Description] - Resolved by [PR/Issue link]
3. [Description] - Resolved by [PR/Issue link]

## Top Unresolved Friction (In Progress)

1. [Description] - Status: [roadmap item / in progress / known limitation]
2. [Description] - Status: [...]
3. [Description] - Status: [...]

## Impact Metrics

- Time to First Deploy: [current metric]
- CSAT Score: [current metric]
- Support ticket volume: [trend]

## Roadmap Preview

Based on friction reports, next quarter priorities:
- [Initiative 1]
- [Initiative 2]
- [Initiative 3]
```

**Why Public**: Demonstrates platform responsiveness, builds tenant trust

---

## Metrics to Track

From MEASUREMENT_MODEL.md:

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Friction Point Submission Volume** | Track trend (should increase initially as awareness grows, then decrease as friction resolves) | Count of GitHub Discussions |
| **Resolution Rate** | ≥70% closed within quarter | Closed Discussions / Total Discussions |
| **Average Resolution Time** | Quick fixes: <1 week, Roadmap items: variable | Time from submission to "Resolved" label |
| **High-Impact Friction Resolved** | 100% addressed (resolved or documented limitation) | Count of "impact: high" + "status: resolved" or "status: known-limitation" |
| **Friction-to-Roadmap Conversion** | ≥50% of roadmap items driven by friction reports | Count of Issues created from Discussions |

**Dashboard**: DX PM maintains public dashboard showing these metrics

---

## Success Criteria

The friction feedback mechanism succeeds when:

- ✅ **Tenants submit friction regularly** (awareness and trust that it matters)
- ✅ **Friction volume decreases over time** (platform improving)
- ✅ **Resolution rate is high** (≥70% closed within quarter)
- ✅ **Roadmap is friction-driven** (≥50% of initiatives trace to friction reports)
- ✅ **Tenants see closed loop** (submit friction → see it resolved → changelog mentions it)

**Anti-Success**:
- ❌ Friction reports go into black hole
- ❌ No response or triage within 2 weeks
- ❌ High-impact friction ignored for quarters
- ❌ Roadmap driven by platform team preferences, not tenant pain

---

## Anti-Patterns to Avoid

### Dismissing Valid Friction

**Symptom**: "That's not friction, you're just doing it wrong"

**Problem**: Discourages future reports, signals platform team doesn't value tenant feedback

**Prevention**: Even if user error, ask "why was this confusing?" → documentation gap

---

### Analysis Paralysis

**Symptom**: Every friction point requires weeks of discussion before action

**Problem**: Quick fixes don't get deployed, teams give up on reporting

**Prevention**: Bias toward action for low-risk fixes (doc updates, scripts)

---

### Ignoring Demand Signals

**Symptom**: 5 teams report same friction, still not prioritized

**Problem**: Platform optimizes for wrong things, tenant trust erodes

**Prevention**: Use upvotes/duplicates to drive prioritization

---

### Feature Creep Via Friction

**Symptom**: Every friction point becomes a massive roadmap item

**Problem**: Simple problems get over-engineered

**Prevention**: Prefer minimal fixes, validate before building

---

## Office Hours Integration

**Weekly Platform Office Hours**:
- Review recent friction points
- Discuss workarounds for known limitations
- Clarify platform decisions
- Collect informal feedback

**Monthly DX Review**:
- Present friction trends to tenants
- Explain roadmap impact
- Celebrate resolved friction

**Anti-Pattern**: Office hours become complaint sessions without follow-through

---

## Related Documentation

- **MEASUREMENT_MODEL.md** — Metrics for tracking friction feedback effectiveness
- **OPERATING_MODEL.md** — Platform-Tenant Collaboration Model
- **DEVELOPER_EXPERIENCE.md** — User journeys where friction occurs
- **POC_GOVERNANCE.md** — Capability request process (related but separate)

---

## Strategic Role

The friction feedback mechanism converts platform improvement from:

**Guesswork**
(platform team guesses what tenants need)

to

**Evidence-Based**
(platform team solves actual tenant pain)

When feedback works:

- Tenants feel heard and see results
- Platform team focuses on high-impact work
- Roadmap aligns with real needs, not assumptions
- Friction decreases measurably over time
- Trust between platform and tenants grows

This is the operational implementation of DORA's finding:

> "Platforms succeed when they prioritize clear feedback on task outcomes and continuously eliminate friction based on user research."

---

## Quick Start Guide

**For Tenants**:

1. Hit a friction point? Submit to GitHub Discussions → "Friction Points"
2. Use template, be specific about impact and frequency
3. Upvote others' friction points you also experience
4. Watch for DX PM triage response (target: <1 week)
5. Track resolution in changelog

**For DX PM (Xavier, for now)**:

1. Weekly: Review new friction point submissions, triage and label
2. Monthly: Review trends with platform team, update roadmap
3. Quarterly: Publish friction report summary
4. Ongoing: Convert quick fixes to PRs, roadmap items to Issues

**For Platform Team**:

1. Monitor "friction: [category]" labels for relevant items
2. Prioritize quick fixes (<1 day) when possible
3. Include friction-driven items in roadmap planning
4. Update changelog when friction is resolved
5. Celebrate friction reduction as success metric

---

## Implementation Checklist

**Initial Setup** (Formation Phase):

- [ ] Enable GitHub Discussions on `platform-docs` repository
- [ ] Create "Friction Points" discussion category
- [ ] Pin friction point submission template as guidance
- [ ] Announce feedback mechanism to all tenant teams
- [ ] Add friction feedback link to platform documentation
- [ ] Schedule weekly DX PM triage time
- [ ] Schedule monthly platform team review

**Ongoing Operations**:

- [ ] Weekly triage by DX PM
- [ ] Monthly trend review with platform team
- [ ] Quarterly public friction report
- [ ] Track metrics in MEASUREMENT_MODEL.md dashboard

**Measurement**:

- [ ] Count friction submissions (expect initial spike as awareness grows)
- [ ] Track resolution rate (target ≥70%)
- [ ] Monitor high-impact friction (100% addressed)
- [ ] Measure Time to First Deploy trend (should decrease as friction resolves)

---

## Example Friction Point Lifecycle

**Week 1**: Tenant submits "Adding database requires 30min of manual docker-compose edits"

**Week 1 (Triage)**: DX PM labels `friction: automation`, `impact: high`, `status: triaged`, comments "Great catch, this affects onboarding for any workload with persistence. Adding to roadmap for generator automation."

**Week 2-8**: Marked as roadmap item, linked to generator Epic

**Week 9**: Platform team implements generator feature to auto-create docker-compose from contract

**Week 10**: PR merged, DX PM comments "Resolved in PR #456, now `zave init` generates docker-compose automatically", closes Discussion with `status: resolved`

**Quarter End**: Included in friction report: "Resolved: Database setup friction reduced from 30min to <1min via generator automation"

**Result**: Time to First Deploy decreases, CSAT improves, tenant trust in feedback mechanism increases
