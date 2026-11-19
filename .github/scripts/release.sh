#!/usr/bin/env bash
# Usage: release.sh <commit-sha> <tag> <backend-image-tag> <frontend-image-tag>
#   e.g. release.sh 6f013a6… v2026.11.20.3 api-v2026.11.20.41 app-v2026.11.20.57
# Creates the GitHub Release for a commit that deploy.yml just applied to prod, or updates it if
# it already exists. <tag> comes from release-tag.sh, which deploy.yml runs before the apply, so
# the version the app shows (/env.js) and the release always match.
# Notes: the images now live in prod + GitHub's generated list of PRs merged since the previous
# v* tag.
# Requires: GH_TOKEN (contents: write), GITHUB_REPOSITORY, a clone with full history.
# DRY_RUN=1 prints the notes and creates nothing (generate-notes is read-only).
set -euo pipefail

SHA="$1"
TAG="$2"
BACKEND_TAG="$3"
FRONTEND_TAG="$4"
REPO="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
OWNER="${REPO%%/*}"

git fetch --quiet --force --tags origin

# Previous release = newest v* tag already contained in this commit's history.
PREV=$(git tag --merged "$SHA" --list 'v[0-9]*' --sort=-v:refname | grep -vxF "$TAG" | head -1 || true)

echo "Release ${TAG} → ${SHA} (previous: ${PREV:-none})"

ARGS=(-f "tag_name=$TAG" -f "target_commitish=$SHA")
if [ -n "$PREV" ]; then
  ARGS+=(-f "previous_tag_name=$PREV")
fi
GENERATED=$(gh api "repos/$REPO/releases/generate-notes" "${ARGS[@]}" --jq .body)

NOTES=$(cat <<NOTES_EOF
## Deployed images
- \`ghcr.io/$OWNER/tasknote/server:$BACKEND_TAG\`
- \`ghcr.io/$OWNER/tasknote/client:$FRONTEND_TAG\`

$GENERATED
NOTES_EOF
)

if [ "${DRY_RUN:-}" = "1" ]; then
  printf '%s\n' "$NOTES"
  exit 0
fi

if gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1; then
  printf '%s\n' "$NOTES" | gh release edit "$TAG" --repo "$REPO" --notes-file -
  echo "Updated release ${TAG}"
else
  printf '%s\n' "$NOTES" | gh release create "$TAG" --repo "$REPO" --target "$SHA" --title "$TAG" --notes-file -
  echo "Created release ${TAG}"
fi
