#!/bin/bash
# Search all ~/workspace-* folders for the term "react" (case-insensitive)

grep -ril "react" ~/workspace-*/ \
  --include="README.md" \
  2>/dev/null \
  | sed 's|^\(.*/workspace-[^/]*/[^/]*\)/.*|\1|' \
  | sort -u

if [ $? -ne 0 ]; then
    echo "No matches found."
fi
