#!/usr/bin/env bash
#
# ZaveStudios Formation Audit Script
#
# Audits Formation phase metrics by scanning repositories listed in REPO_TAXONOMY.md
#
# Usage: ./formation-audit.sh [--verbose]
#
# Requirements:
# - Run from workspace root (default: ~/Dev, override with WORKSPACE_ROOT env var)
# - All repositories must be cloned locally

set -euo pipefail

WORKSPACE_ROOT="${WORKSPACE_ROOT:-$HOME/Dev}"
VERBOSE="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TAXONOMY_PATH="$REPO_ROOT/_platform/REPO_TAXONOMY.md"

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Metrics counters (simple variables for bash 3.x compatibility)
total_tenant_portfolio=0
total_poc=0
workloads_with_contract=0
workloads_with_valid_contract=0
workloads_with_docker_compose=0
workloads_with_env_example=0
workloads_with_readme_local_dev=0
pocs_with_readme=0
pocs_with_system_design_template=0
pocs_with_metadata=0
missing_repo_count=0

# Repository arrays (derived from REPO_TAXONOMY.md)
TENANT_REPOS=()
PORTFOLIO_REPOS=()
POC_REPOS=()

if [[ ! -f "$TAXONOMY_PATH" ]]; then
    echo -e "${RED}ERROR:${NC} taxonomy file not found at $TAXONOMY_PATH"
    exit 1
fi

while IFS='|' read -r repo category; do
    case "$category" in
        tenant)
            TENANT_REPOS+=("$repo")
            ;;
        portfolio)
            PORTFOLIO_REPOS+=("$repo")
            ;;
        poc)
            POC_REPOS+=("$repo")
            ;;
    esac
done < <(
    awk -F'|' '
        /^\| `/ {
            repo = $2
            category = $3
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", repo)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", category)
            gsub(/`/, "", repo)
            gsub(/`/, "", category)
            if (category == "tenant" || category == "portfolio" || category == "poc") {
                print repo "|" category
            }
        }
    ' "$TAXONOMY_PATH"
)

# Combine tenant and portfolio for workload checks
WORKLOAD_REPOS=("${TENANT_REPOS[@]}" "${PORTFOLIO_REPOS[@]}")

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   ZaveStudios Formation Phase Audit               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Workspace: $WORKSPACE_ROOT"
echo "Taxonomy:  $TAXONOMY_PATH"
echo "Timestamp: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo ""

#
# Workload Audit (tenant + portfolio repositories)
#

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Contract Adoption Metrics${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

for repo in "${WORKLOAD_REPOS[@]}"; do
    repo_path="$WORKSPACE_ROOT/$repo"
    total_tenant_portfolio=$((total_tenant_portfolio + 1))

    if [[ ! -d "$repo_path" ]]; then
        missing_repo_count=$((missing_repo_count + 1))
        echo -e "${RED}[MISSING]${NC} $repo - repository not found locally"
        continue
    fi

    # Check for zave.yaml
    has_contract=false
    contract_valid=false

    if [[ -f "$repo_path/zave.yaml" ]]; then
        has_contract=true
        workloads_with_contract=$((workloads_with_contract + 1))

        # Basic validation: check for required fields
        if grep -q "apiVersion:" "$repo_path/zave.yaml" && \
           grep -q "kind: Workload" "$repo_path/zave.yaml" && \
           grep -q "metadata:" "$repo_path/zave.yaml" && \
           grep -q "spec:" "$repo_path/zave.yaml"; then
            contract_valid=true
            workloads_with_valid_contract=$((workloads_with_valid_contract + 1))
        fi
    fi

    if [[ "$VERBOSE" == "--verbose" ]]; then
        if [[ "$has_contract" == true ]]; then
            if [[ "$contract_valid" == true ]]; then
                echo -e "${GREEN}[✓]${NC} $repo - zave.yaml present and valid"
            else
                echo -e "${YELLOW}[!]${NC} $repo - zave.yaml present but missing required fields"
            fi
        else
            echo -e "${RED}[✗]${NC} $repo - zave.yaml missing"
        fi
    fi
done

# Calculate percentages
if [[ $total_tenant_portfolio -gt 0 ]]; then
    contract_adoption_pct=$((workloads_with_contract * 100 / total_tenant_portfolio))
    contract_valid_pct=$((workloads_with_valid_contract * 100 / total_tenant_portfolio))
else
    contract_adoption_pct=0
    contract_valid_pct=0
fi

echo ""
echo "Contract Adoption: $workloads_with_contract/$total_tenant_portfolio ($contract_adoption_pct%)"
echo "Valid Contracts:   $workloads_with_valid_contract/$total_tenant_portfolio ($contract_valid_pct%)"

if [[ $contract_adoption_pct -ge 80 ]]; then
    echo -e "${GREEN}✓ Formation Exit Criterion: ≥80% contract adoption MET${NC}"
else
    echo -e "${YELLOW}○ Formation Exit Criterion: ≥80% contract adoption NOT MET (current: $contract_adoption_pct%)${NC}"
fi

echo ""

#
# Developer Experience Standardization Metrics
#

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Developer Experience Standardization Metrics${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

for repo in "${WORKLOAD_REPOS[@]}"; do
    repo_path="$WORKSPACE_ROOT/$repo"

    if [[ ! -d "$repo_path" ]]; then
        if [[ "$VERBOSE" == "--verbose" ]]; then
            echo "$repo: repository-missing"
        fi
        continue
    fi

    # Check for docker-compose
    has_docker_compose=false
    if [[ -f "$repo_path/docker-compose.yml" ]] || [[ -f "$repo_path/docker-compose.yaml" ]]; then
        has_docker_compose=true
        workloads_with_docker_compose=$((workloads_with_docker_compose + 1))
    fi

    # Check for .env.example
    has_env_example=false
    if [[ -f "$repo_path/.env.example" ]]; then
        has_env_example=true
        workloads_with_env_example=$((workloads_with_env_example + 1))
    fi

    # Check for README with "Local Development" section
    has_readme_local_dev=false
    if [[ -f "$repo_path/README.md" ]]; then
        if grep -q "## Local Development" "$repo_path/README.md" || \
           grep -q "# Local Development" "$repo_path/README.md"; then
            has_readme_local_dev=true
            workloads_with_readme_local_dev=$((workloads_with_readme_local_dev + 1))
        fi
    fi

    if [[ "$VERBOSE" == "--verbose" ]]; then
        echo -n "$repo: "
        [[ "$has_docker_compose" == true ]] && echo -n "docker-compose✓ " || echo -n "docker-compose✗ "
        [[ "$has_env_example" == true ]] && echo -n ".env.example✓ " || echo -n ".env.example✗ "
        [[ "$has_readme_local_dev" == true ]] && echo -n "README✓" || echo -n "README✗"
        echo ""
    fi
done

# Calculate percentages
if [[ $total_tenant_portfolio -gt 0 ]]; then
    docker_compose_pct=$((workloads_with_docker_compose * 100 / total_tenant_portfolio))
    env_example_pct=$((workloads_with_env_example * 100 / total_tenant_portfolio))
    readme_local_dev_pct=$((workloads_with_readme_local_dev * 100 / total_tenant_portfolio))
else
    docker_compose_pct=0
    env_example_pct=0
    readme_local_dev_pct=0
fi

echo ""
echo "docker-compose:      $workloads_with_docker_compose/$total_tenant_portfolio ($docker_compose_pct%)"
echo ".env.example:        $workloads_with_env_example/$total_tenant_portfolio ($env_example_pct%)"
echo "README Local Dev:    $workloads_with_readme_local_dev/$total_tenant_portfolio ($readme_local_dev_pct%)"

if [[ $docker_compose_pct -eq 100 ]]; then
    echo -e "${GREEN}✓ Formation Exit Criterion: 100% docker-compose MET${NC}"
else
    echo -e "${YELLOW}○ Formation Exit Criterion: 100% docker-compose NOT MET (current: $docker_compose_pct%)${NC}"
fi

echo ""

#
# POC Governance Metrics
#

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}POC Governance Metrics${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

for repo in "${POC_REPOS[@]}"; do
    repo_path="$WORKSPACE_ROOT/$repo"
    total_poc=$((total_poc + 1))

    if [[ ! -d "$repo_path" ]]; then
        missing_repo_count=$((missing_repo_count + 1))
        if [[ "$VERBOSE" == "--verbose" ]]; then
            echo -e "${RED}[MISSING]${NC} $repo - repository not found locally"
        fi
        continue
    fi

    # Check for README
    has_readme=false
    has_system_design=false
    has_metadata=false

    if [[ -f "$repo_path/README.md" ]]; then
        has_readme=true
        pocs_with_readme=$((pocs_with_readme + 1))

        # Check for System Design Interview template sections
        if grep -q "## Step 1: Understand the Problem" "$repo_path/README.md" && \
           grep -q "## Step 2: Propose High-Level Design" "$repo_path/README.md" && \
           grep -q "## Step 3: Design Deep Dive" "$repo_path/README.md" && \
           grep -q "## Step 4: Wrap Up" "$repo_path/README.md"; then
            has_system_design=true
            pocs_with_system_design_template=$((pocs_with_system_design_template + 1))
        fi

        # Check for governance metadata
        if grep -q "\*\*Status:\*\*" "$repo_path/README.md"; then
            has_metadata=true
            pocs_with_metadata=$((pocs_with_metadata + 1))
        fi
    fi

    if [[ "$VERBOSE" == "--verbose" ]]; then
        echo -n "$repo: "
        [[ "$has_readme" == true ]] && echo -n "README✓ " || echo -n "README✗ "
        [[ "$has_system_design" == true ]] && echo -n "SysDesign✓ " || echo -n "SysDesign✗ "
        [[ "$has_metadata" == true ]] && echo -n "Metadata✓" || echo -n "Metadata✗"
        echo ""
    fi
done

# Calculate percentages
if [[ $total_poc -gt 0 ]]; then
    poc_readme_pct=$((pocs_with_readme * 100 / total_poc))
    poc_template_pct=$((pocs_with_system_design_template * 100 / total_poc))
    poc_metadata_pct=$((pocs_with_metadata * 100 / total_poc))
else
    poc_readme_pct=0
    poc_template_pct=0
    poc_metadata_pct=0
fi

echo ""
echo "README present:      $pocs_with_readme/$total_poc ($poc_readme_pct%)"
echo "System Design tpl:   $pocs_with_system_design_template/$total_poc ($poc_template_pct%)"
echo "Governance metadata: $pocs_with_metadata/$total_poc ($poc_metadata_pct%)"

if [[ $poc_template_pct -eq 100 ]] && [[ $poc_metadata_pct -eq 100 ]] && [[ $total_poc -gt 0 ]]; then
    echo -e "${GREEN}✓ POC Governance: 100% compliance MET${NC}"
else
    if [[ $total_poc -eq 0 ]]; then
        echo -e "${YELLOW}○ POC Governance: No POC repositories found${NC}"
    else
        echo -e "${YELLOW}○ POC Governance: Not all POCs have required structure${NC}"
    fi
fi

echo ""

#
# Formation Exit Criteria Summary
#

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Formation Exit Criteria Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

exit_criteria_met=0
exit_criteria_total=5

# 1. Contract dominance (≥80%)
if [[ $contract_adoption_pct -ge 80 ]]; then
    echo -e "${GREEN}[✓]${NC} Contract Dominance: ≥80% workloads with zave.yaml ($contract_adoption_pct%)"
    exit_criteria_met=$((exit_criteria_met + 1))
else
    echo -e "${RED}[✗]${NC} Contract Dominance: ≥80% workloads with zave.yaml ($contract_adoption_pct%)"
fi

# 2. Developer experience consistency (100% docker-compose)
if [[ $docker_compose_pct -eq 100 ]]; then
    echo -e "${GREEN}[✓]${NC} DX Consistency: 100% workloads with docker-compose"
    exit_criteria_met=$((exit_criteria_met + 1))
else
    echo -e "${RED}[✗]${NC} DX Consistency: 100% workloads with docker-compose ($docker_compose_pct%)"
fi

# 3. GitOps authority (100% deployments via GitOps) - Manual check required
echo -e "${YELLOW}[?]${NC} GitOps Authority: 100% deployments via GitOps (requires manual verification)"

# 4. Generator readiness (zave init exists) - Manual check required
echo -e "${YELLOW}[?]${NC} Generator Readiness: \`zave init\` command exists (requires manual verification)"

# 5. Tenant self-service (<2 onboarding support tickets/month) - Manual check required
echo -e "${YELLOW}[?]${NC} Tenant Self-Service: <2 support tickets per month (requires manual verification)"

echo ""
if [[ $missing_repo_count -gt 0 ]]; then
    echo -e "${RED}Workspace incomplete:${NC} $missing_repo_count in-scope repositories from REPO_TAXONOMY.md are missing locally."
    echo "Metrics above count missing repositories in the denominator and should not be treated as full coverage."
    echo ""
fi

echo "Automated Criteria Met: $exit_criteria_met/2 (automated checks only)"
echo "Manual Verification Required: 3 criteria (GitOps, Generator, Support Tickets)"
echo ""

if [[ $exit_criteria_met -eq 2 ]]; then
    echo -e "${GREEN}All automated Formation exit criteria MET!${NC}"
    echo "Proceed with manual verification of remaining criteria."
else
    echo -e "${YELLOW}Formation exit criteria NOT fully met (automated checks).${NC}"
    echo "Continue Formation phase activities to improve metrics."
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Audit complete. See MEASUREMENT_MODEL.md for metric definitions."
echo "For verbose output, run: $0 --verbose"

if [[ $missing_repo_count -gt 0 ]]; then
    exit 2
fi
