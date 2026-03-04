#!/usr/bin/env bash
set -euo pipefail

# Apply class-based Terraform branch protections to all repos in an org
# that carry the "terraform" topic.
#
# Usage:
#   ./scripts/apply-terraform-repo-protection-bulk.sh zavestudios

ORG="${1:?org required}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

repos="$(gh api "orgs/$ORG/repos" --paginate --jq '.[] | select(.archived == false) | .name')"

count=0
while IFS= read -r repo; do
  [[ -z "$repo" ]] && continue
  topics="$(gh api "repos/$ORG/$repo/topics" --jq '.names')"
  if echo "$topics" | jq -e 'index("terraform") != null' >/dev/null; then
    "$SCRIPT_DIR/apply-terraform-repo-protection.sh" "$ORG" "$repo"
    count=$((count + 1))
  fi
done <<< "$repos"

echo "Applied protections to $count terraform repos in $ORG."
