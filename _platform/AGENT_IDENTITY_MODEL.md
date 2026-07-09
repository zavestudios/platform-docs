# ZaveStudios — Agent Identity Model v0.1

## Chapter Guide

**Purpose**

Define how human and agent GitHub identities are used for commits, pull
requests, comments, reviews, approvals, and command-line fallback.

**Read this when**

- configuring local `gh` authentication for agents
- deciding which identity should author a commit or review
- auditing contribution attribution
- debugging GitHub App or CLI fallback behavior

**Read next**

- `PR_WORKFLOW.md` for branch, commit, and pull request mechanics
- `EXECUTION_ENVIRONMENTS.md` for where GitHub commands should run
- `OPERATING_MODEL.md` for cross-repository change expectations

---

## Identity Inventory

ZaveStudios uses separate GitHub identities for the human owner and each coding
agent.

| Actor | GitHub user | Purpose |
| --- | --- | --- |
| Human owner | `eckslopez` | final authority, merges, human-authored work, administrative actions |
| Codex | `codex-zavestudios` | Codex-authored commits, comments, reviews, and approved fallback GitHub operations |
| Claude Code | `claude-zavestudios` | Claude Code-authored commits, comments, reviews, and approved fallback GitHub operations |

Shared generic agent identities should not be used for new work unless they are
explicitly retained as a temporary migration bridge.

---

## Attribution Rules

### Human Owner

Use `eckslopez` for:

- human-authored commits
- repository administration
- merges
- final approval decisions that require human authority
- actions where legal, billing, organization, or security authority matters

### Agent Identities

Use the agent's dedicated identity for work the agent performs:

- Codex uses `codex-zavestudios`
- Claude Code uses `claude-zavestudios`

This applies to:

- commits authored by that agent
- pull request comments
- issue comments
- pull request reviews
- approvals, when the human has explicitly allowed agent approval for that
  workflow
- `gh` CLI fallback when the GitHub App or connector cannot perform the action

Do not have one agent approve, comment, or commit as another agent.

---

## Commit Authorship

Agent-authored commits should use the agent's machine-user Git identity.

Commit messages may include a generation footer identifying the tool that
produced the change. The author identity and footer must not contradict each
other.

Example:

```text
Add observability operator workflow

Generated with Codex

Co-Authored-By: Codex <codex-zavestudios@users.noreply.github.com>
```

For human-authored work, use the human Git identity and omit agent generation
footers unless an agent materially contributed to the patch.

---

## Review And Approval Rules

Agent reviews must be attributed to the reviewing agent's account.

Allowed:

- `codex-zavestudios` reviews Claude Code-authored work.
- `claude-zavestudios` reviews Codex-authored work.
- Either agent comments on its own pull request with implementation status.

Avoid:

- approving a pull request with the same account that authored the branch
- approving as `eckslopez` when the review judgment came from an agent
- approving as a generic shared agent account

Human review remains the final authority when repository protection, risk, or
platform policy requires it.

---

## Local Authentication Expectations

Each agent workstation/session should have a reliable way to use its assigned
GitHub identity without ad hoc token selection.

Expected local `gh` shape:

```bash
gh auth status
```

should show the relevant machine user available for GitHub operations.

When global account switching is unreliable, commands may use an explicit token
for a single operation, for example:

```bash
GH_TOKEN="$(gh auth token --user codex-zavestudios)" gh pr review 123 --approve
```

This is acceptable as a fallback only when it preserves correct attribution.

---

## Validation Checklist

Before considering an agent identity operational, verify:

- the GitHub user is a member of the `ZaveStudios` organization
- the user has the required repository permissions
- `gh auth status` shows the user locally
- issue comments can be authored as that user
- pull request comments can be authored as that user
- pull request reviews can be submitted as that user
- commits authored by that user attribute correctly in GitHub
- fallback CLI operations do not require manual token guessing

Record unsupported GitHub App or connector operations as explicit fallback
cases instead of rediscovering them during active work.

---

## See Also

- `PR_WORKFLOW.md`
- `EXECUTION_ENVIRONMENTS.md`
- `OPERATING_MODEL.md`
