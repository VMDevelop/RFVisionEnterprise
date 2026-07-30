#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -d .git ]]; then
  git init
fi

git add .
if git diff --cached --quiet; then
  echo "No changes to commit."
else
  git commit -m "chore: bootstrap RF Vision Enterprise baseline"
fi

echo
echo "Repository initialized at: $ROOT"
echo "Add the GitHub remote manually, then push main."
