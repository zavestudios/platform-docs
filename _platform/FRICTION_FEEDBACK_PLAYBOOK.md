# ZaveStudios — Friction Feedback Playbook v0.1

This document provides the operating appendix for the platform friction feedback
mechanism.

## Chapter Guide

**Purpose**

Provide the recurring review flow, templates, checklists, and working examples
for operating the friction feedback mechanism.

**Read this when**

- standing up the friction program
- running the monthly or quarterly review cadence
- preparing public reports, templates, or implementation checklists

**Read next**

- `FRICTION_FEEDBACK.md` for the core policy
- `MEASUREMENT_MODEL.md` for metric framing
- `AUDIT_PROGRAM.md` when friction handling becomes part of formal review

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
   - Update `MEASUREMENT_MODEL.md` friction point volume tracking
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

## Metrics To Track

From `MEASUREMENT_MODEL.md`:

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

## Anti-Patterns To Avoid

### Dismissing Valid Friction

**Symptom**: "That's not friction, you're just doing it wrong"

**Problem**: Discourages future reports, signals platform team doesn't value
tenant feedback

**Prevention**: Even if user error, ask "why was this confusing?" →
documentation gap

### Analysis Paralysis

**Symptom**: Every friction point requires weeks of discussion before action

**Problem**: Quick fixes don't get deployed, teams give up on reporting

**Prevention**: Bias toward action for low-risk fixes (doc updates, scripts)

### Ignoring Demand Signals

**Symptom**: 5 teams report same friction, still not prioritized

**Problem**: Platform optimizes for wrong things, tenant trust erodes

**Prevention**: Use upvotes/duplicates to drive prioritization

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

## Quick Start Guide

**For Tenants**:

1. Hit a friction point? Submit to GitHub Discussions → "Friction Points"
2. Use template, be specific about impact and frequency
3. Upvote others' friction points you also experience
4. Watch for DX PM triage response (target: <1 week)
5. Track resolution in changelog

**For DX PM**:

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
- [ ] Track metrics in `MEASUREMENT_MODEL.md` dashboard

**Measurement**:

- [ ] Count friction submissions (expect initial spike as awareness grows)
- [ ] Track resolution rate (target ≥70%)
- [ ] Monitor high-impact friction (100% addressed)
- [ ] Measure Time to First Deploy trend (should decrease as friction resolves)

---

## Example Friction Point Lifecycle

**Week 1**: Tenant submits "Adding database requires 30min of manual
docker-compose edits"

**Week 1 (Triage)**: DX PM labels `friction: automation`, `impact: high`,
`status: triaged`, comments "Great catch, this affects onboarding for any
workload with persistence. Adding to roadmap for generator automation."

**Week 2-8**: Marked as roadmap item, linked to generator Epic

**Week 9**: Platform team implements generator feature to auto-create
docker-compose from contract

**Week 10**: PR merged, DX PM comments "Resolved in PR #456, now `zave init`
generates docker-compose automatically", closes Discussion with
`status: resolved`

**Quarter End**: Included in friction report: "Resolved: Database setup
friction reduced from 30min to <1min via generator automation"

**Result**: Time to First Deploy decreases, CSAT improves, tenant trust in
feedback mechanism increases

---

## See Also

- `FRICTION_FEEDBACK.md`
- `MEASUREMENT_MODEL.md`
- `DEVELOPER_EXPERIENCE_JOURNEYS.md`
- `AUDIT_PROGRAM.md`
