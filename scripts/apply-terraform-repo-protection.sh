#!/usr/bin/env bash
set -euo pipefail

# Apply class-based branch protection to a single Terraform repo.
# Class is determined from topics: modules | sandbox | production.
#
# Usage:
#   ./scripts/apply-terraform-repo-protection.sh zavestudios iac-tf-sbx-example

ORG="${1:?org required}"
REPO="${2:?repo required}"
FULL_REPO="${ORG}/${REPO}"

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required." >&2
  exit 1
fi

DEFAULT_BRANCH="$(gh repo view "$FULL_REPO" --json defaultBranchRef --jq '.defaultBranchRef.name')"
TOPICS_JSON="$(gh api "repos/$FULL_REPO/topics" --jq '.names')"

has_topic() {
  local topic="$1"
  echo "$TOPICS_JSON" | jq -e --arg t "$topic" 'index($t) != null' >/dev/null
}

required_reviews=1
require_code_owner_review=false

if has_topic "production"; then
  required_reviews=2
  require_code_owner_review=true
elif has_topic "modules"; then
  required_reviews=1
  require_code_owner_review=true
elif has_topic "sandbox"; then
  required_reviews=1
  require_code_owner_review=false
else
  echo "ERROR: missing class topic. Expected one of: modules, sandbox, production." >&2
  echo "Topics: $TOPICS_JSON" >&2
  exit 1
fi

payload="$(jq -n \
  --argjson reviews "$required_reviews" \
  --argjson codeowners "$require_code_owner_review" \
'{
  required_status_checks: null,
  enforce_admins: true,
  required_pull_request_reviews: {
    dismiss_stale_reviews: true,
    require_code_owner_reviews: $codeowners,
    require_last_push_approval: false,
    required_approving_review_count: $reviews
  },
  restrictions: null,
  required_linear_history: true,
  allow_force_pushes: false,
  allow_deletions: false,
  block_creations: false,
  required_conversation_resolution: true,
  lock_branch: false,
  allow_fork_syncing: false
}')"

echo "Applying protection to $FULL_REPO@$DEFAULT_BRANCH"
echo "Topics: $TOPICS_JSON"
echo "required_reviews=$required_reviews require_code_owner_review=$require_code_owner_review"

gh api -X PUT "repos/$FULL_REPO/branches/$DEFAULT_BRANCH/protection" --input - <<<"$payload" >/dev/null

echo "Done."
