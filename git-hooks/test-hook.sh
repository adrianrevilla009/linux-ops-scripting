#!/usr/bin/env bash
# Verify the pre-commit hook in a throwaway repo.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
git init -q .
git config user.email t@example.com
git config user.name t
install -m 755 "$here/pre-commit" .git/hooks/pre-commit

echo "echo ok" > ok.sh
git add ok.sh
git commit -q -m clean
echo "clean commit allowed"

echo "key=AKI""AABCDEFGHIJKLMNOP" > leak.txt
git add leak.txt
if git commit -q -m leak 2>/dev/null; then
  echo "FAIL: secret was committed" >&2
  exit 1
fi
echo "PASS: secret commit blocked"
