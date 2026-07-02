# shellcheck shell=bash
# Lefthook-compatible local filesystem path detector.
# Usage: lefthook-git-no-local-paths file1 [file2 ...]
# NOTE: sourced by writeShellApplication — no shebang or set needed.

if [ $# -eq 0 ]; then
  exit 0
fi

files=()
for f in "$@"; do
  [ -f "$f" ] || continue
  files+=("$f")
done

if [ ${#files[@]} -eq 0 ]; then
  exit 0
fi

found=0
for f in "${files[@]}"; do
  if grep -HnE '/Users/[a-zA-Z0-9._-]|/home/[a-zA-Z0-9._-]|/root/|/tmp/[a-zA-Z0-9._-]' -- "$f" | grep -v '# nolocalpath'; then
    found=1
  fi
done

exit "$found"
