# Pull Request Workflow

## Chapter Guide

**Purpose**

Define the standard change path for governed repositories.

**Read this when**

- preparing to land a platform change
- checking whether a branch, commit, or review flow is conformant
- deciding how durable follow-up work from an incident should be carried

**Read next**

- `OPERATING_MODEL.md` for cross-repo change expectations
- `RUNBOOK_METHODOLOGY.md` for converting incident findings into follow-up work
- `DEVELOPER_EXPERIENCE.md` for local branch and workspace conventions

## Standard Workflow

When completing work on a feature branch:

1. **Push branch to remote:**
   ```bash
   git push -u origin <branch-name>
   ```

2. **Create pull request via GitHub CLI:**
   ```bash
   gh pr create --title "Title" --body "Description" --base main
   ```

3. **Wait for review:**
   - Never merge locally to main
   - All merges require human review and approval
   - CI/CD must pass before merge

4. **Never commit directly to main:**
   - All changes go through feature branches and PRs
   - Main branch is protected

## Branch Naming Conventions

- `feature/` - New features or capabilities
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring without behavior change

## PR Title Format

Use imperative mood and be concise:
- "Add multi-tenant database isolation"
- "Fix contract validation for static runtime"
- "Update developer experience standards"

## PR Description

Include:
- Summary of changes
- Related issues (if applicable)
- Testing performed
- Breaking changes (if any)

## Commit Message Standards

All commits should include Claude Code co-authorship footer:

```
Descriptive commit message

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

## Why This Workflow

**Ensures:**
- All changes are reviewable and documented
- Branch history is preserved
- CI/CD validation before merge
- Human approval gate for all changes
- Architectural review for cross-repo changes

**Prevents:**
- Unreviewed changes in production
- Lost work from force pushes
- Breaking changes without discussion
- Direct main branch commits

---

## See Also

- `OPERATING_MODEL.md`
- `RUNBOOK_METHODOLOGY.md`
- `DEVELOPER_EXPERIENCE.md`
- `ENFORCEMENT_MATRIX.md`
