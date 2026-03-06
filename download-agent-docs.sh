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

if [ -d "agent_docs" ]; then
  read -p "This will replace your existing shared and $TYPE directories. Do you want to continue? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
      exit 1
  fi
else
    mkdir -p agent_docs
fi

echo "Downloading agent_docs/shared..."
npx tiged "$REPO/agent_docs/shared" agent_docs/shared --force

echo "Downloading agent_docs/$TYPE..."
npx tiged "$REPO/agent_docs/$TYPE" "agent_docs/$TYPE" --force

if [ -f "AGENTS.md" ]; then
  source "agent_docs/shared/update-toc.sh"
fi

echo "Done. agent_docs/ is ready."
