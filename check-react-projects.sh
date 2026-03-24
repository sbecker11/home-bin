#!/bin/bash
# Check each project for actual React usage indicators

PROJECTS=(
  "/Users/sbecker11/workspace-2D/affine-xform-tool"
  "/Users/sbecker11/workspace-airflow/venv"
  "/Users/sbecker11/workspace-anthropic/anthropic-tools"
  "/Users/sbecker11/workspace-apollo/my-apollo-app"
  "/Users/sbecker11/workspace-claude/weather"
  "/Users/sbecker11/workspace-color-palette-maker/color-palette-maker-nodejs"
  "/Users/sbecker11/workspace-color-palette-maker/color-palette-maker-ruby"
  "/Users/sbecker11/workspace-fastapi/fastapi-vue"
  "/Users/sbecker11/workspace-fastapi/fastapi-vue-vuelidate.keep"
  "/Users/sbecker11/workspace-flock/flock-of-postcards"
  "/Users/sbecker11/workspace-flock/resume-flock"
  "/Users/sbecker11/workspace-gallery/photo-gallery-project"
  "/Users/sbecker11/workspace-jraw/notesapp"
  "/Users/sbecker11/workspace-json-schema/node_modules"
  "/Users/sbecker11/workspace-linear-clone/linear-clone"
  "/Users/sbecker11/workspace-ml/ml-app-cdk"
  "/Users/sbecker11/workspace-mlops/create-iam-user-aws-cdk"
  "/Users/sbecker11/workspace-ms/docx-to-txt"
  "/Users/sbecker11/workspace-pdf-to-llm/pdf-to-txt"
  "/Users/sbecker11/workspace-php/spexture"
  "/Users/sbecker11/workspace-react/react-super-app"
  "/Users/sbecker11/workspace-react/spexture-com"
  "/Users/sbecker11/workspace-resume/flat-viewer"
  "/Users/sbecker11/workspace-resume/resume-parser-node"
  "/Users/sbecker11/workspace-rolodex/node_modules"
  "/Users/sbecker11/workspace-slider/dual-layer-slider"
  "/Users/sbecker11/workspace-spa/spa-monorepo"
  "/Users/sbecker11/workspace-spa/spa-react"
  "/Users/sbecker11/workspace-spa/spa-react-2"
  "/Users/sbecker11/workspace-spa/spa-vue"
  "/Users/sbecker11/workspace-spexture/node_modules"
  "/Users/sbecker11/workspace-sushi/sushi-agent"
  "/Users/sbecker11/workspace-sushi/sushi-rag-app"
  "/Users/sbecker11/workspace-svelte/mysveltsite"
  "/Users/sbecker11/workspace-telerus/telerus"
  "/Users/sbecker11/workspace-test/react-super-app"
  "/Users/sbecker11/workspace-threejs/coordinate-axes"
  "/Users/sbecker11/workspace-threejs/munsell-space"
  "/Users/sbecker11/workspace-typescript/radial-cluster-2"
  "/Users/sbecker11/workspace-typescript/sankey-diagram-app"
  "/Users/sbecker11/workspace-webui/open-webui"
)

for proj in "${PROJECTS[@]}"; do
  if [ ! -d "$proj" ] || echo "$proj" | grep -qi "keep"; then
    continue
  fi

  name=$(echo "$proj" | sed 's|.*/workspace-[^/]*/||')
  has_react_dep=false
  has_jsx_tsx=false
  has_react_import=false

  # Check package.json for react dependency
  if [ -f "$proj/package.json" ]; then
    if grep -q '"react"' "$proj/package.json" 2>/dev/null; then
      has_react_dep=true
    fi
  fi

  # Check for .jsx or .tsx files (excluding node_modules/venv)
  jsx_count=$(find "$proj" -type f \( -name "*.jsx" -o -name "*.tsx" \) \
    -not -path "*/node_modules/*" \
    -not -path "*/venv/*" \
    -not -path "*/.venv/*" \
    2>/dev/null | wc -l | tr -d ' ')

  if [ "$jsx_count" -gt 0 ]; then
    has_jsx_tsx=true
  fi

  # Check for React imports in source files (excluding node_modules/venv)
  if grep -rl "from ['\"]react['\"]" "$proj" \
    --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" \
    --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=.venv \
    2>/dev/null | head -1 | grep -q .; then
    has_react_import=true
  fi

  # Report results
  if $has_react_dep || $has_jsx_tsx || $has_react_import; then
    echo "✅ $name"
    $has_react_dep    && echo "     react in package.json"
    $has_jsx_tsx      && echo "     $jsx_count .jsx/.tsx files"
    $has_react_import && echo "     React imports in source"
  else
    echo "❌ $name (mention only)"
  fi
done
