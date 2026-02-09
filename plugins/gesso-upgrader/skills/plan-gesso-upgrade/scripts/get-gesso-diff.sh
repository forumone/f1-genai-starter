#!/usr/bin/env bash
set -euo pipefail

REPO="forumone/gesso"

# Walk up from the current directory to find the nearest package.json that
# belongs to a Gesso theme (contains "forumone/gesso" or a gesso-related name).
# This handles both standalone Gesso repos and Gesso nested inside a Drupal site.
find_gesso_package_json() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/package.json" ]] && grep -q '"name".*gesso' "$dir/package.json"; then
      echo "$dir/package.json"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

PACKAGE_JSON="$(find_gesso_package_json)" || {
  echo "Error: Could not find a Gesso package.json in any parent directory" >&2
  exit 1
}

CURRENT_VERSION=$(grep -o '"version": *"[^"]*"' "$PACKAGE_JSON" | head -1 | grep -o '"[^"]*"$' | tr -d '"')

if [[ -z "$CURRENT_VERSION" ]]; then
  echo "Error: Could not read version from package.json" >&2
  exit 1
fi

echo "Current theme version: $CURRENT_VERSION"

# Get all releases from GitHub, sorted by semver (newest first)
RELEASES=$(gh release list --repo "$REPO" --limit 5 --json tagName --jq '.[].tagName')

if [[ -z "$RELEASES" ]]; then
  echo "Error: Could not fetch releases from $REPO" >&2
  exit 1
fi

# Find the next release after the current version.
# Releases come newest-first, so we look for the first tag that is greater
# than the current version when sorted by semver.
NEXT_VERSION=""
while IFS= read -r tag; do
  # Compare using sort -V (version sort). If the tag sorts after the current
  # version, it is newer. We want the smallest such tag (the immediate next
  # release).
  if [[ "$tag" == "$CURRENT_VERSION" ]]; then
    continue
  fi
  # Check if this tag is newer than current version
  HIGHER=$(printf '%s\n%s\n' "$CURRENT_VERSION" "$tag" | sort -V | tail -1)
  if [[ "$HIGHER" == "$tag" ]]; then
    # This tag is newer. Keep the smallest newer tag.
    if [[ -z "$NEXT_VERSION" ]]; then
      NEXT_VERSION="$tag"
    else
      SMALLER=$(printf '%s\n%s\n' "$NEXT_VERSION" "$tag" | sort -V | head -1)
      if [[ "$SMALLER" == "$tag" ]]; then
        NEXT_VERSION="$tag"
      fi
    fi
  fi
done <<< "$RELEASES"

if [[ -z "$NEXT_VERSION" ]]; then
  echo "No newer release found after $CURRENT_VERSION. You are up to date!"
  exit 0
fi

echo "Next Gesso release: $NEXT_VERSION"
echo ""
echo "Fetching diff between $CURRENT_VERSION and $NEXT_VERSION..."
echo "---"

# Use the GitHub compare API via gh to get the diff
gh api "repos/$REPO/compare/$CURRENT_VERSION...$NEXT_VERSION" \
  --header "Accept: application/vnd.github.v3.diff"
