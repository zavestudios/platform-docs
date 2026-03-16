# ZaveStudios Platform Scripts

This directory contains automation scripts for platform operations and measurement.

---

## formation-audit.sh

**Purpose**: Audit Formation phase metrics by scanning repositories listed in REPO_TAXONOMY.md

**What it checks**:

### Contract Adoption Metrics
- % of workloads (tenant + portfolio) with `zave.yaml`
- % of workloads with valid contract structure (apiVersion, kind, metadata, spec)

### Developer Experience Standardization
- % of workloads with `docker-compose.yml` or `docker-compose.yaml`
- % of workloads with `.env.example`
- % of workloads with README "Local Development" section

### POC Governance Compliance
- % of POCs with README.md
- % of POCs with System Design Interview template
- % of POCs with governance metadata (Status, Author, Date)

### Formation Exit Criteria
- Contract dominance: ≥80% workloads with zave.yaml
- DX consistency: 100% workloads with docker-compose
- GitOps authority: manual verification required
- Generator readiness: manual verification required
- Tenant self-service: manual verification required

---

## Usage

### Basic Run

```bash
cd /Users/xavierlopez/Dev
./platform-docs/_scripts/formation-audit.sh
```

**Output**: Summary metrics and Formation exit criteria status

---

### Verbose Run

```bash
cd /Users/xavierlopez/Dev
./platform-docs/_scripts/formation-audit.sh --verbose
```

**Output**: Per-repository detailed compliance checks plus summary

---

## Requirements

- Run from workspace root (`/Users/xavierlopez/Dev`)
- All repositories listed in REPO_TAXONOMY.md must be cloned locally
- Script reads file presence, does not require running services

---

## Exit Codes

- `0`: Script completed successfully (does not indicate all criteria met)
- Non-zero: Script error (missing dependencies, filesystem issues, etc.)

---

## Frequency

**Recommended Cadence**:

- **Weekly** during Formation phase: Track progress toward exit criteria
- **Monthly** after Formation exit: Ensure no regression in standards

**DX PM Responsibility**: Run weekly, include metrics in monthly platform review

---

## Sample Output

```
╔════════════════════════════════════════════════════╗
║   ZaveStudios Formation Phase Audit               ║
╚════════════════════════════════════════════════════╝

Workspace: /Users/xavierlopez/Dev
Timestamp: 2026-03-16 20:30:00 UTC

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Contract Adoption Metrics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Contract Adoption: 8/8 (100%)
Valid Contracts:   8/8 (100%)
✓ Formation Exit Criterion: ≥80% contract adoption MET

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Developer Experience Standardization Metrics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

docker-compose:      8/8 (100%)
.env.example:        8/8 (100%)
README Local Dev:    8/8 (100%)
✓ Formation Exit Criterion: 100% docker-compose MET

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Formation Exit Criteria Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[✓] Contract Dominance: ≥80% workloads with zave.yaml (100%)
[✓] DX Consistency: 100% workloads with docker-compose
[?] GitOps Authority: requires manual verification
[?] Generator Readiness: requires manual verification
[?] Tenant Self-Service: requires manual verification

Automated Criteria Met: 2/2 (automated checks only)
```

---

## Integration with MEASUREMENT_MODEL.md

This script automates the "Formation Phase Metrics" described in MEASUREMENT_MODEL.md:

| Metric (from MEASUREMENT_MODEL.md) | Automated by Script | Manual Check Required |
|------------------------------------|---------------------|-----------------------|
| % workloads with zave.yaml | ✓ | |
| % workloads with valid contract | ✓ | |
| % workloads with docker-compose | ✓ | |
| % workloads with .env.example | ✓ | |
| % workloads with README Local Dev | ✓ | |
| % POCs with System Design template | ✓ | |
| % POCs with governance metadata | ✓ | |
| % deployments via GitOps | | Manual GitOps audit |
| Generator exists (`zave init`) | | Check if command available |
| Support ticket volume | | Review ticket system |

---

## Future Enhancements

Potential improvements for post-Formation:

- **JSON output mode**: For dashboard integration
- **GitOps audit**: Scan gitops repository for workload registration
- **Trend tracking**: Store results over time, show improvement graphs
- **CI integration**: Run on PR to platform-docs, comment with metrics
- **Notification**: Slack/Discord notification if metrics regress
- **Repository health scores**: Per-repo compliance rating

---

## Troubleshooting

### "repository not found locally"

**Cause**: Repository listed in REPO_TAXONOMY.md is not cloned in workspace

**Fix**: Clone missing repository or remove from REPO_TAXONOMY.md if decommissioned

---

### "grep: pattern not found"

**Cause**: File exists but doesn't contain expected pattern

**Fix**: This is expected for non-compliant repositories. Script counts these as not meeting criteria.

---

### Script fails with "permission denied"

**Cause**: Script not executable

**Fix**:
```bash
chmod +x /Users/xavierlopez/Dev/platform-docs/_scripts/formation-audit.sh
```

---

## Related Documentation

- **MEASUREMENT_MODEL.md** — Defines metrics this script measures
- **REPO_TAXONOMY.md** — Source of truth for repository list
- **DEVELOPER_EXPERIENCE.md** — Standards being measured
- **POC_GOVERNANCE.md** — POC requirements being checked
- **CONTRACT_SCHEMA.md** — Contract structure validated by script

---

## Maintenance

**Who maintains**: Platform team (currently: Xavier as DX PM)

**Update triggers**:
- REPO_TAXONOMY.md changes (add/remove repositories)
- New Formation metrics defined
- Contract schema validation rules change
- POC governance template changes

**Version**: Follows platform-docs versioning (currently v0.1)
