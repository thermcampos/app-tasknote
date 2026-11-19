#!/usr/bin/env bash
# Usage: release-tag.sh <commit-sha>
# Prints the release tag for a commit about to be deployed. deploy.yml runs this BEFORE the
# Terraform apply, so the client pod can serve the tag in /env.js (RELEASE_VERSION). After the
# apply, release.sh creates the GitHub Release under the same tag.
#   - The commit already has a v* tag (an earlier deploy released it, e.g. a PR touching both
#     sides deploys twice): reuse it, so a re-deploy changes nothing.
#   - Otherwise: v<UTC date>.<RELEASE_NUMBER> (default GITHUB_RUN_NUMBER of the deploy).
# Requires a clone with full history.
set -euo pipefail

SHA="$1"

git fetch --quiet --force --tags origin

TAG=$(git tag --points-at "$SHA" --list 'v[0-9]*' --sort=-v:refname | head -1)
if [ -z "$TAG" ]; then
  TAG="v$(date -u +%Y.%m.%d).${RELEASE_NUMBER:-${GITHUB_RUN_NUMBER:?GITHUB_RUN_NUMBER is required}}"
fi

echo "$TAG"
