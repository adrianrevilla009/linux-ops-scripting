#!/usr/bin/env bash
# Offline lint: recipe code blocks must parse as shell and only contain read-only verbs.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
blocks=$(awk '/^```bash/{on=1;next} /^```/{on=0} on' "$here/recipes.md")

bash -n <<< "$blocks"
echo "syntax ok"

if grep -Eq '\b(delete|terminate|destroy|rm|put|create|update)\b' <<< "$blocks"; then
  echo "FAIL: mutating verb found in recipes" >&2
  exit 1
fi
echo "PASS: recipes parse and are read-only"
