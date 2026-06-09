#!/usr/bin/env bash
# setup-branch-protection.sh
# Configures branch protection on main for all Malstrom framework repos.
# Requires: gh CLI authenticated (gh auth login)
#
# Rules enforced:
#   - No direct push to main
#   - PRs required (1 approval OR just CI pass for solo repos)
#   - Squash merge only
#   - Status checks must pass (giskard validate)
#   - No force push, no branch deletion
#
# Usage: bash scripts/setup-branch-protection.sh

set -euo pipefail

REPOS=(
  "Malstrom/zeroth"
  "Malstrom/giskard"
  "Malstrom/dojo"
  "Malstrom/tensho"
  "Malstrom/sudo-hire-me"
)

protect() {
  local repo=$1
  echo "[setup] protecting main on $repo..."

  # Branch protection rules via gh API
  gh api \
    --method PUT \
    -H "Accept: application/vnd.github+json" \
    "/repos/${repo}/branches/main/protection" \
    --field required_status_checks='{"strict":true,"contexts":["validate"]}' \
    --field enforce_admins=true \
    --field required_pull_request_reviews='{"required_approving_review_count":0,"dismiss_stale_reviews":false}' \
    --field restrictions=null \
    --field allow_force_pushes=false \
    --field allow_deletions=false \
    --field required_linear_history=true

  # Squash merge only — disable merge commits and rebase
  gh api \
    --method PATCH \
    -H "Accept: application/vnd.github+json" \
    "/repos/${repo}" \
    --field allow_merge_commit=false \
    --field allow_squash_merge=true \
    --field allow_rebase_merge=false \
    --field squash_merge_commit_title="PR_TITLE" \
    --field squash_merge_commit_message="PR_BODY"

  echo "[setup] ✅ $repo protected"
}

for repo in "${REPOS[@]}"; do
  protect "$repo"
done

echo ""
echo "[setup] done. All repos: no direct push, squash-only, CI required."
