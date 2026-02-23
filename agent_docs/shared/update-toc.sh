#!/usr/bin/env bash
# update-toc.sh — Adds or replaces the agent_docs TOC in ../AGENTS.md
# Run from: agent_docs/shared/ (or anywhere; paths resolve relative to this script)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DOCS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_MD="$(cd "$AGENT_DOCS_DIR/.." && pwd)/AGENTS.md"

if [[ ! -f "$AGENTS_MD" ]]; then
  echo "Error: AGENTS.md not found at $AGENTS_MD" >&2
  exit 1
fi

# Build the minified TOC.
# Format:
#   [Agent Docs Index]|root: ./agent_docs
#   |IMPORTANT: Prefer retrieval-led reasoning over pre-training-led reasoning
#   |dir/subdir:{file1.md,file2.md,...}
build_toc() {
  echo "[Agent Docs Index]|root: ./agent_docs"
  echo "|IMPORTANT: Prefer retrieval-led reasoning over pre-training-led reasoning"

  # Find all .md files, strip the agent_docs prefix, then group by directory.
  # awk preserves insertion order and is bash-3 safe.
  find "$AGENT_DOCS_DIR" -type f -name "*.md" | sort | \
    sed "s|^$AGENT_DOCS_DIR/||" | \
    awk -F'/' '
      {
        # Reconstruct dir as everything except the last segment (the filename)
        file = $NF
        dir = ""
        for (i = 1; i < NF; i++) {
          dir = (i == 1) ? $i : dir "/" $i
        }
        if (dir in files) {
          files[dir] = files[dir] "," file
        } else {
          files[dir] = file
          order[++n] = dir
        }
      }
      END {
        for (i = 1; i <= n; i++) {
          d = order[i]
          print "|" d ":{" files[d] "}"
        }
      }
    '
}

TOC_START="<!-- agent-docs-toc-start -->"
TOC_END="<!-- agent-docs-toc-end -->"

NEW_TOC="${TOC_START}
\`\`\`
$(build_toc)
\`\`\`
${TOC_END}"

if grep -qF "$TOC_START" "$AGENTS_MD"; then
  # Replace existing TOC block in-place using python3 (available on macOS/Linux).
  python3 - "$AGENTS_MD" "$TOC_START" "$TOC_END" "$NEW_TOC" <<'PYEOF'
import sys, re
path, start_marker, end_marker, new_block = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
text = open(path).read()
pattern = re.escape(start_marker) + r'.*?' + re.escape(end_marker)
result = re.sub(pattern, new_block, text, flags=re.DOTALL)
open(path, 'w').write(result)
PYEOF
  echo "TOC updated in $AGENTS_MD"
else
  # Prepend TOC before existing content.
  TMP="$(mktemp)"
  printf '%s\n\n%s\n' "$NEW_TOC" "$(cat "$AGENTS_MD")" > "$TMP"
  mv "$TMP" "$AGENTS_MD"
  echo "TOC added to $AGENTS_MD"
fi
