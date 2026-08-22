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
  matches=$(grep -HnE '/Users/[a-zA-Z0-9._-]|/home/[a-zA-Z0-9._-]|/roo''t/|/tmp/[a-zA-Z0-9._-]' -- "$f" || true)

  case "$f" in
    .github/CODEOWNERS | .github/CODEOWNERS.* | */.github/CODEOWNERS | */.github/CODEOWNERS.*)
      # CODEOWNERS patterns may start with / to mean the repository root.
      matches=$(printf '%s\n' "$matches" | grep -vE '^[^:]+:[0-9]+:[[:space:]]*/' || true)
      ;;
  esac

  if printf '%s\n' "$matches" | grep -v '# nolocalpath' | grep -q .; then
    printf '%s\n' "$matches" | grep -v '# nolocalpath' | grep .
    found=1
  fi
done

exit "$found"
