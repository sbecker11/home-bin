#!/usr/bin/env bash
# Print paths under $HOME that are either:
#   - ~/workspace-*  (one level), or
#   - ~/workspace-*/* (two levels, e.g. workspace-color-palette/color-palette-maker)
# modified after a cutoff, and that:
#   1) are git projects
#   2) have README.md
#   3) have origin pointing at github.com (or git@github.com:)
#
# After each path: FE, BE, folder mtime, url: https://github.com/... (browser-openable), README bytes, source stats, commits (--all)
# (RECENT_GIT_PATHS_ONLY=1 → path only).
# Set RECENT_GIT_CUTOFF, RECENT_GIT_PATTERN as needed.

# Sourced: BASH_SOURCE[0] is this file; $0 is the parent shell. Executed: they match.
if [[ -n "${BASH_VERSION:-}" && "${BASH_SOURCE[0]}" != "$0" ]]; then
  printf '%s\n' "recent-git-projects.sh: do not source this script; run it directly, e.g. ~/bin/recent-git-projects.sh" >&2
  return 2 2>/dev/null || exit 2
fi

set -uo pipefail

CUTOFF="${RECENT_GIT_CUTOFF:-2025-01-01}"
PATTERN="${RECENT_GIT_PATTERN:-workspace-*}"

is_github_remote() {
  local url="$1"
  [[ "$url" == *github.com* ]] || [[ "$url" == github:* ]]
}

# --- tech stack heuristics (append-only; dedupe at print) ---
fe_tags=()
be_tags=()

add_fe() {
  local t="$1"
  local x
  for x in "${fe_tags[@]:-}"; do [[ "$x" == "$t" ]] && return; done
  fe_tags+=("$t")
}

add_be() {
  local t="$1"
  local x
  for x in "${be_tags[@]:-}"; do [[ "$x" == "$t" ]] && return; done
  be_tags+=("$t")
}

# Merge dependency keys from package.json (stdout: one key per line)
package_dep_keys() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  if command -v jq &>/dev/null && jq empty "$f" 2>/dev/null; then
    jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' "$f" 2>/dev/null
  elif command -v python3 &>/dev/null; then
    python3 -c "
import json, sys
try:
    with open(sys.argv[1], encoding='utf-8') as fp:
        p = json.load(fp)
    d = {**(p.get('dependencies') or {}), **(p.get('devDependencies') or {})}
    print('\n'.join(sorted(d.keys())))
except Exception:
    pass
" "$f" 2>/dev/null
  fi
}

classify_npm_key() {
  local k="$1"
  local pkg="${2:-}"
  case "$k" in
    react-native|react-native-*)
      add_fe "React Native"
      ;;
    react|react-dom|@types/react)
      add_fe "React"
      ;;
    nuxt|@nuxt/*)
      add_fe "Nuxt"
      add_be "Nuxt (Node)"
      ;;
    vue|vue-router|@vue/cli*|@vue/*)
      add_fe "Vue"
      ;;
    @angular/*|angular)
      add_fe "Angular"
      ;;
    @sveltejs/kit)
      add_fe "SvelteKit"
      add_be "SvelteKit (Node)"
      ;;
    svelte)
      add_fe "Svelte"
      ;;
    next)
      add_fe "Next.js"
      add_be "Next.js (API / Node)"
      ;;
    @remix-run/*|remix)
      add_fe "Remix"
      add_be "Remix (Node)"
      ;;
    astro)
      add_fe "Astro"
      ;;
    gatsby)
      add_fe "Gatsby"
      ;;
    vite|@vitejs/*)
      add_fe "Vite"
      ;;
    webpack|webpack-cli)
      add_fe "Webpack"
      ;;
    parcel|@parcel/*)
      add_fe "Parcel"
      ;;
    solid-js)
      add_fe "Solid"
      ;;
    preact)
      add_fe "Preact"
      ;;
    express)
      add_be "Express (Node)"
      ;;
    fastify)
      add_be "Fastify (Node)"
      ;;
    koa|@koa/*)
      add_be "Koa (Node)"
      ;;
    @nestjs/*|nestjs)
      add_be "NestJS (Node)"
      ;;
    @hapi/hapi|hapi)
      add_be "Hapi (Node)"
      ;;
    hono)
      add_be "Hono (Node)"
      ;;
    polka)
      add_be "Polka (Node)"
      ;;
    socket.io)
      add_be "Socket.io"
      ;;
    typescript)
      case "$pkg" in
        */server/package.json|*/api/package.json)
          add_be "TypeScript"
          ;;
        *)
          add_fe "TypeScript"
          ;;
      esac
      ;;
    esac
}

scan_package_json_tree() {
  local root="$1"
  local f
  for f in \
    "$root/package.json" \
    "$root/client/package.json" \
    "$root/frontend/package.json" \
    "$root/web/package.json" \
    "$root/server/package.json" \
    "$root/api/package.json"
  do
    [[ -f "$f" ]] || continue
    local key
    while IFS= read -r key; do
      [[ -n "$key" ]] || continue
      classify_npm_key "$key" "$f"
    done < <(package_dep_keys "$f")
  done
}

# Case-insensitive blob match for Python/Ruby etc.
blob_has() {
  local blob="$1"
  local needle="$2"
  printf '%s' "$blob" | tr '[:upper:]' '[:lower:]' | grep -qF "$(printf '%s' "$needle" | tr '[:upper:]' '[:lower:]')"
}

scan_python() {
  local root="$1"
  local blob=""
  local p
  for p in \
    "$root/pyproject.toml" \
    "$root/requirements.txt" \
    "$root/requirements-dev.txt" \
    "$root/Pipfile"
  do
    [[ -f "$p" ]] && blob+=$(<"$p")$'\n'
  done
  [[ -n "$blob" ]] || return 0
  blob_has "$blob" django && add_be "Django (Python)"
  blob_has "$blob" flask && add_be "Flask (Python)"
  blob_has "$blob" fastapi && add_be "FastAPI (Python)"
  blob_has "$blob" starlette && add_be "Starlette (Python)"
  blob_has "$blob" uvicorn && add_be "Uvicorn (Python)"
  blob_has "$blob" tornado && add_be "Tornado (Python)"
  blob_has "$blob" streamlit && add_fe "Streamlit (Python)"
  # generic Python web if something matched nothing but pyproject has project
  if [[ ${#be_tags[@]} -eq 0 ]] && [[ -f "$root/pyproject.toml" ]]; then
    add_be "Python (pyproject)"
  elif [[ ${#be_tags[@]} -eq 0 ]] && [[ -n "$blob" ]]; then
    add_be "Python (deps file)"
  fi
}

scan_ruby() {
  local root="$1"
  local g="$root/Gemfile"
  [[ -f "$g" ]] || return 0
  local blob
  blob=$(<"$g")
  blob_has "$blob" rails && add_be "Rails (Ruby)"
  blob_has "$blob" sinatra && add_be "Sinatra (Ruby)"
  blob_has "$blob" grape && add_be "Grape (Ruby)"
  blob_has "$blob" puma && add_be "Puma (Ruby)"
  if [[ ${#be_tags[@]} -eq 0 ]]; then
    add_be "Ruby (Gemfile)"
  fi
}

scan_go_rust_php() {
  local root="$1"
  [[ -f "$root/go.mod" ]] && add_be "Go"
  [[ -f "$root/Cargo.toml" ]] && add_be "Rust"
  if [[ -f "$root/composer.json" ]]; then
    local blob
    blob=$(<"$root/composer.json")
    if blob_has "$blob" laravel; then
      add_be "Laravel (PHP)"
    else
      add_be "PHP (Composer)"
    fi
  fi
}

# Root server.js with express when package.json did not list express (rare monorepos)
scan_node_entry_hint() {
  local root="$1"
  local x
  for x in "${be_tags[@]:-}"; do
    [[ "$x" == *Express* ]] && return 0
  done
  [[ -f "$root/server.js" || -f "$root/index.js" || -f "$root/app.js" ]] || return 0
  local f
  for f in "$root/server.js" "$root/index.js" "$root/app.js"; do
    [[ -f "$f" ]] || continue
    if grep -qE "require\\(['\"]express['\"]\\)|from ['\"]express['\"]" "$f" 2>/dev/null; then
      add_be "Express (Node, inferred)"
      break
    fi
  done
}

# If package.json did not list typescript (or only nested manifests were scanned), still flag TS.
infer_typescript_if_missing() {
  local root="$1" t tracked
  for t in "${fe_tags[@]:-}"; do [[ "$t" == "TypeScript" ]] && return 0; done
  for t in "${be_tags[@]:-}"; do [[ "$t" == "TypeScript" ]] && return 0; done
  if [[ -f "$root/tsconfig.json" ]]; then
    add_fe "TypeScript"
    return 0
  fi
  tracked=$(git -C "$root" ls-files '*.ts' '*.tsx' 2>/dev/null) || tracked=
  [[ -n "$tracked" ]] && add_fe "TypeScript"
}

print_fe_be_lines() {
  local root="$1"
  fe_tags=()
  be_tags=()

  scan_package_json_tree "$root"
  scan_python "$root"
  scan_ruby "$root"
  scan_go_rust_php "$root"
  scan_node_entry_hint "$root"
  infer_typescript_if_missing "$root"

  local fe be
  if [[ ${#fe_tags[@]} -eq 0 ]]; then
    fe="—"
  else
    fe=$(printf '%s, ' "${fe_tags[@]}")
    fe=${fe%, }
  fi
  if [[ ${#be_tags[@]} -eq 0 ]]; then
    be="—"
  else
    be=$(printf '%s, ' "${be_tags[@]}")
    be=${be%, }
  fi

  printf 'FE: %s\n' "$fe"
  printf 'BE: %s\n' "$be"
}

# Human-readable last modification time of the directory (best-effort portable)
folder_mtime_display() {
  local p="$1" out sec
  out=$(stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S %z' "$p" 2>/dev/null) && [[ -n "$out" ]] && {
    printf '%s\n' "$out"
    return 0
  }
  out=$(date -r "$p" '+%Y-%m-%d %H:%M:%S %z' 2>/dev/null) && [[ -n "$out" ]] && {
    printf '%s\n' "$out"
    return 0
  }
  sec=$(stat -c '%Y' "$p" 2>/dev/null) || sec=
  [[ -n "$sec" ]] && out=$(date -d "@$sec" '+%Y-%m-%d %H:%M:%S %z' 2>/dev/null) && [[ -n "$out" ]] && {
    printf '%s\n' "$out"
    return 0
  }
  printf '%s\n' "—"
}

# Tracked files only (git ls-files); common source extensions. Tab-separated: count lines
source_file_stats() {
  local root="$1"
  local f path n=0 sum=0 lc
  while IFS= read -r -d '' f; do
    case "$f" in
      *.js|*.jsx|*.mjs|*.cjs|*.ts|*.tsx|*.vue|*.svelte) ;;
      *.py|*.pyw|*.go|*.rs|*.java|*.kt|*.kts) ;;
      *.c|*.h|*.cpp|*.hpp|*.cc|*.cs) ;;
      *.rb|*.php|*.swift) ;;
      *.css|*.scss|*.sass|*.less) ;;
      *.sh|*.sql|*.html|*.htm) ;;
      *) continue ;;
    esac
    path="$root/$f"
    [[ -f "$path" ]] || continue
    lc=$(wc -l <"$path" 2>/dev/null | awk '{print $1}')
    [[ -n "$lc" ]] || lc=0
    n=$((n + 1))
    sum=$((sum + lc))
  done < <(git -C "$root" ls-files -z 2>/dev/null)
  printf '%s\t%s\n' "$n" "$sum"
}

# Normalize origin to https://github.com/owner/repo (no .git, no trailing slash)
github_repo_https_url() {
  local raw="$1" u o r
  [[ -n "$raw" ]] || return 1
  u="$raw"
  u="${u%.git}"
  case "$u" in
    git@github.com:*|github.com:*)
      u=${u#git@}
      u=${u#github.com:}
      o=${u%%/*}
      r=${u#*/}
      r=${r%%/*}
      printf 'https://github.com/%s/%s\n' "$o" "$r"
      return 0
      ;;
    ssh://git@github.com/*)
      u=${u#ssh://git@github.com/}
      o=${u%%/*}
      r=${u#*/}
      r=${r%%/*}
      printf 'https://github.com/%s/%s\n' "$o" "$r"
      return 0
      ;;
    git://github.com/*)
      u=${u#git://github.com/}
      o=${u%%/*}
      r=${u#*/}
      r=${r%%/*}
      printf 'https://github.com/%s/%s\n' "$o" "$r"
      return 0
      ;;
    https://github.com/*|http://github.com/*)
      u=${u#https://github.com/}
      u=${u#http://github.com/}
      o=${u%%/*}
      r=${u#*/}
      r=${r%%/*}
      r=${r%%\?*}
      printf 'https://github.com/%s/%s\n' "$o" "$r"
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

print_project_meta() {
  local root="$1"
  printf 'Folder date (mtime): %s\n' "$(folder_mtime_display "$root")"
  local origin_url web_url
  origin_url=$(git -C "$root" remote get-url origin 2>/dev/null) || origin_url=
  if web_url=$(github_repo_https_url "$origin_url"); then
    printf 'url: %s\n' "$web_url"
  else
    printf 'url: —\n'
  fi
  local readme="$root/README.md"
  local bytes
  bytes=$(wc -c <"$readme" 2>/dev/null | awk '{print $1}')
  [[ -n "$bytes" ]] || bytes="—"
  printf 'README.md size: %s bytes\n' "$bytes"
  local sfiles slines
  IFS=$'\t' read -r sfiles slines < <(source_file_stats "$root")
  printf 'Source files: %s\n' "${sfiles:-0}"
  printf 'Source lines: %s\n' "${slines:-0}"
  local commits
  commits=$(git -C "$root" rev-list --count --all 2>/dev/null) || commits=
  [[ -n "$commits" ]] || commits="—"
  printf 'Commits: %s\n' "$commits"
}

# Row of hyphens across the terminal (COLUMNS, tput cols, or 80)
print_terminal_width_divider() {
  local w cols line
  w=${COLUMNS:-}
  if [[ -z "$w" ]] && cols=$(tput cols 2>/dev/null); then
    w=$cols
  fi
  if [[ -z "$w" || "$w" -lt 1 ]]; then
    w=80
  fi
  printf -v line '%*s' "$w" ''
  printf '%s\n' "${line// /-}"
}

while IFS= read -r -d '' d; do
  [[ -d "$d/.git" ]] || continue
  [[ -f "$d/README.md" ]] || continue
  remote=$(git -C "$d" remote get-url origin 2>/dev/null) || continue
  [[ -n "$remote" ]] || continue
  is_github_remote "$remote" || continue
  print_terminal_width_divider
  printf '%s\n' "$d"
  if [[ "${RECENT_GIT_PATHS_ONLY:-0}" != "1" ]]; then
    print_fe_be_lines "$d"
    print_project_meta "$d"
  fi
done < <({
  find "$HOME" -mindepth 1 -maxdepth 1 -type d -name "$PATTERN" -newermt "$CUTOFF" -print0
  find "$HOME" -mindepth 2 -maxdepth 2 -type d -path "$HOME/${PATTERN}/*" -newermt "$CUTOFF" -print0
})
