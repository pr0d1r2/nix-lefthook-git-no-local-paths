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
    if grep -HnE '/Users/[a-zA-Z]|/home/[a-zA-Z]|/root/' "$f" | grep -v '# nolocalpath'; then
        found=1
    fi
done

exit "$found"
