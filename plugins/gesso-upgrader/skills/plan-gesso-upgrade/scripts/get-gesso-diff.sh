#!/usr/bin/env bash
set -euo pipefail

REPO="forumone/gesso"

# Check for required dependencies
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required but not installed. Please install jq to continue." >&2
  exit 1
fi

# Find the package.json that belongs to the Gesso theme.
# Strategy 1: walk up from $PWD (covers running from inside the theme).
# Strategy 2: search down from the git root or $PWD (covers running from the
#             project root, e.g. when invoked via a skill).
find_gesso_package_json() {
  # Walk up
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/package.json" ]] && grep -q '"name".*gesso' "$dir/package.json"; then
      echo "$dir/package.json"
      return 0
    fi
    dir="$(dirname "$dir")"
  done

  # Search down from the git root (if available) or $PWD
  local search_root
  search_root="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
  local found
  found="$(find "$search_root" -name "package.json" \
    -not -path "*/node_modules/*" \
    -exec grep -l '"name".*gesso' {} + 2>/dev/null | head -1)"
  if [[ -n "$found" ]]; then
    echo "$found"
    return 0
  fi

  return 1
}

PACKAGE_JSON="$(find_gesso_package_json)" || {
  echo "Error: Could not find a Gesso package.json in any parent directory or within the project" >&2
  exit 1
}

CURRENT_VERSION=$(grep -o '"version": *"[^"]*"' "$PACKAGE_JSON" | head -1 | grep -o '"[^"]*"$' | tr -d '"')

if [[ -z "$CURRENT_VERSION" ]]; then
  echo "Error: Could not read version from package.json" >&2
  exit 1
fi

echo "Current theme version: $CURRENT_VERSION"

# Get all releases from GitHub, sorted by semver (newest first)
RELEASES=$(curl -sf "https://api.github.com/repos/$REPO/releases?per_page=5" | jq -r '.[].tag_name')

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

# Use the GitHub compare API to get the diff, excluding package-lock.json
curl -sf -H "Accept: application/vnd.github.v3.diff" \
  "https://api.github.com/repos/$REPO/compare/$CURRENT_VERSION...$NEXT_VERSION" | \
  awk '
    /^diff --git/ {
      in_package_lock = ($0 ~ /package-lock\.json/)
      if (!in_package_lock) print
      next
    }
    !in_package_lock { print }
  '
