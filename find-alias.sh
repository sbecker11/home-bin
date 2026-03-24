#!/bin/bash
# Script to find which file defines an alias, function, or variable
# Usage: ./find-alias.sh <alias_name>

# Check if alias name was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <alias_name>"
  echo ""
  echo "Example: $0 paths"
  echo "         $0 ll"
  echo "         $0 gs"
  exit 1
fi

ALIAS_NAME="$1"

echo "Searching for '$ALIAS_NAME' definition..."
echo ""

# List of files to check
files=(
  "$HOME/.zshenv"
  "$HOME/.zshrc"
  "$HOME/.zprofile"
  "$HOME/.zlogin"
)

found=false

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    # Check for alias
    if grep -q "alias $ALIAS_NAME" "$file" 2>/dev/null; then
      echo "✓ Found alias in: $file"
      grep -n "alias $ALIAS_NAME" "$file" 2>/dev/null
      found=true
      echo ""
    fi
    # Check for variable/alias assignment (ALIAS_NAME=)
    if grep -q "^$ALIAS_NAME=" "$file" 2>/dev/null; then
      echo "✓ Found assignment in: $file"
      grep -n "^$ALIAS_NAME=" "$file" 2>/dev/null
      found=true
      echo ""
    fi
    # Check for function (ALIAS_NAME())
    if grep -q "^$ALIAS_NAME()" "$file" 2>/dev/null; then
      echo "✓ Found function in: $file"
      grep -n "^$ALIAS_NAME()" "$file" 2>/dev/null
      found=true
      echo ""
    fi
  fi
done

# Also check Oh My Zsh and other common locations
if [ "$found" = false ]; then
  echo "Not found in standard config files. Searching additional locations..."
  echo ""
  
  # Check Oh My Zsh plugins and custom
  additional_files=$(grep -rHl "alias $ALIAS_NAME\|^$ALIAS_NAME=\|^$ALIAS_NAME()" ~/.oh-my-zsh ~/.config/zsh 2>/dev/null | head -5)
  if [ -n "$additional_files" ]; then
    echo "$additional_files" | while read -r file; do
      echo "✓ Found in: $file"
      grep -n "alias $ALIAS_NAME\|^$ALIAS_NAME=\|^$ALIAS_NAME()" "$file" 2>/dev/null | head -3
      echo ""
      found=true
    done
  fi
fi

if [ "$found" = false ]; then
  echo "Not found in standard config files or common locations."
  echo "The '$ALIAS_NAME' may be defined in:"
  echo "  - A sourced file (check source/include statements in your config files)"
  echo "  - Oh My Zsh plugin"
  echo "  - System-wide config"
  echo "  - Dynamically defined"
  echo ""
  echo "To search more broadly, run:"
  echo "  grep -r '$ALIAS_NAME' ~/.oh-my-zsh/ ~/.config/ 2>/dev/null"
  exit 1
else
  exit 0
fi

