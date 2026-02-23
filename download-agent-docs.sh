#!/usr/bin/env bash
set -euo pipefail

REPO="forumone/f1-genai-starter"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <nextjs|drupal>" >&2
  exit 1
fi

TYPE="$1"

if [[ "$TYPE" != "nextjs" && "$TYPE" != "drupal" ]]; then
  echo "Error: argument must be 'nextjs' or 'drupal', got '$TYPE'" >&2
  exit 1
fi

mkdir -p agent_docs

echo "Downloading agent_docs/shared..."
npx tiged "$REPO/agent_docs/shared" agent_docs/shared --force

echo "Downloading agent_docs/$TYPE..."
npx tiged "$REPO/agent_docs/$TYPE" "agent_docs/$TYPE" --force

echo "Done. agent_docs/ is ready."
