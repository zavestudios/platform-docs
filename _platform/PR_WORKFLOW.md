# Pull Request Workflow

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
