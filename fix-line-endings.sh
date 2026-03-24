#!/bin/zsh
# One-off: convert CRLF to LF in shell scripts (recursive)
usage() {
  cat << 'EOF'
Usage: fix-line-endings.sh [file-or-directory]
  converts "CRLF" endings to "LF" in shell scripts recursively
  file:       fix that file only
  directory:  recursively fix all .sh files (default: current dir)
  --help:     show this message

Examples:
  fix-line-endings.sh                    # fix all .sh in current dir
  fix-line-endings.sh scripts/           # fix all .sh under scripts/
  fix-line-endings.sh path/to/script.sh  # fix single file
EOF
}
[[ "$1" == --help || "$1" == -h ]] && { usage; exit 0; }
TARGET="${1:-.}"
if [[ -f "$TARGET" ]]; then
  sed -i '' 's/\r$//' "$TARGET" && echo "Fixed: $TARGET"
else
  find "$TARGET" -type f -name "*.sh" | while read -r f; do
    sed -i '' 's/\r$//' "$f" && echo "Fixed: $f"
  done
fi
