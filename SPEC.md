## §D — Description

nix-lefthook-git-no-local-paths is a Nix-flake-packaged shell script that
detects hardcoded local filesystem paths in git-staged files. It catches
leaked development-environment paths (user home directories, root home,
temp directories) that would break CI or expose machine-specific details.
The tool runs as a lefthook pre-commit/pre-push hook and is intended for
Nix-based projects that enforce reproducible builds. Lines can opt out
with a `# nolocalpath` inline comment.

## §V — Invariants

1. The flake must build and pass `nix flake check` on all four supported
   platforms: aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux.
2. All bats unit tests (`tests/unit/*.bats`) must pass in the CI devShell.
3. Every shell script has a corresponding bats test file under `tests/unit/`.
4. The main script exits 0 when given no arguments or only non-existent files.
5. The main script exits 1 when any scanned file contains a local path not
   suppressed by `# nolocalpath`.
6. Every lefthook command must appear in both `pre-commit` and `pre-push`.
7. Every lefthook command must include a `timeout` wrapper.
8. Shell scripts must not contain function definitions (separate scripts
   instead).
9. Nix files must not embed shell code inline; shell must be extracted to
   `.sh` files read via `builtins.readFile`.
10. All file types tracked in git must have an assigned linter in
    `lefthook.yml`.
11. CI runs on Linux for every PR; macOS runs on push and workflow_dispatch
    only.
12. The `.envrc` must `watch_file` every Nix module and shell fragment the
    flake depends on.

## §I — Interfaces

### CLI

```text
lefthook-git-no-local-paths [file ...]
```

- **Arguments**: zero or more file paths.
- **Exit 0**: no files given, all files non-existent, or no local paths found.
- **Exit 1**: at least one file contains an unsuppressed local path.
- **stdout**: `grep -HnE` output (`file:line:match`) for each offending line.
- **Suppression**: append `# nolocalpath` to a source line to skip it.

### Detected patterns (ERE)

```text
/Users/[a-zA-Z]
/home/[a-zA-Z]   # nolocalpath
/root/  # nolocalpath
/tmp/[a-zA-Z]
```

### Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `LEFTHOOK_GIT_NO_LOCAL_PATHS_TIMEOUT` | `30` | Timeout (seconds) for the hook |
| `LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT` | `60` | Timeout for `nix flake check` hook |
| `BATS_LIB_PATH` | set by devShell | Path to bats helper libraries |

### Config files

| File | Format | Purpose |
|---|---|---|
| `lefthook.yml` | YAML | Main lefthook config with remotes and local commands |
| `lefthook-remote.yml` | YAML | Reusable remote config for consuming repos |
| `config/lefthook/file_size_limits.yml` | YAML | Per-extension file size limits |
| `.envrc` | direnv | Loads the Nix flake devShell |
| `.yamllint.yml` | YAML | yamllint rule overrides |
| `.markdownlint.yml` | YAML | markdownlint rule overrides |
| `.editorconfig` | INI | Editor formatting rules |

### Nix outputs

| Output | Description |
|---|---|
| `packages.<system>.default` | `writeShellApplication` wrapping the detector script |
| `devShells.<system>.ci` | Minimal shell for CI (linters, bats, lefthook) |
| `devShells.<system>.default` | CI shell plus `gh`, with `dev.sh` shellHook |

## §T — Tasks

| status | id | goal |
|---|---|---|
| `x` | T1 | Add markdownlint lefthook remote — `.markdownlint.yml` config exists but no lefthook check enforces it |
| `x` | T2 | Add TOML linter for `.rtk/filters.toml` (linter rule: every tracked file type needs a linter) |
| `x` | T3 | Extract inline shell from `lefthook-nix-no-embedded-shell` wrapper in `nix/lefthook-wrappers.nix` (the `SCANNER=` line is embedded shell unlike all other wrappers) |
| `x` | T4 | Add bats tests for edge cases: binary files, files with only suppressed paths, empty files |
| `x` | T5 | Align `actions/checkout` version in `update-pins.yml` (v4) with `ci.yml` (v6) |
| `.` | T6 | Add bats test verifying that output includes filename and line number (`grep -HnE` format) |
| `.` | T7 | Widen `/tmp/` regex to also catch numeric-prefixed temp dirs (currently requires `[a-zA-Z]` after the slash) |
| `.` | T8 | Add `.envrc` `watch_file` entry for `config/lefthook/file_size_limits.yml` (used by file-size-check wrapper at runtime) |

## §B — Bugs / Known Issues

1. **Regex gap on `/tmp/`**: the pattern `/tmp/[a-zA-Z]` requires an
   alphabetic character immediately after the slash. Paths like
   `/tmp/123-build` or `/tmp/.cache` pass undetected. The same gap exists
   for `/Users/` and `/home/` (numeric usernames, though rare).
2. **Embedded shell in nix wrapper**: `nix/lefthook-wrappers.nix` line 58
   concatenates a `SCANNER=` shell assignment with `builtins.readFile`,
   producing inline shell in a Nix file. All other wrappers use pure
   `readFile`.
3. **Missing markdownlint hook**: `.markdownlint.yml` is present but no
   lefthook command or remote enforces markdown linting, violating the
   "every file type needs a linter" invariant.
4. **`# nolocalpath` is greedy**: the suppression is a post-filter
   (`grep -v`), so it fires on any matching line that also contains the
   string `# nolocalpath` anywhere — including inside string literals or
   unrelated comments.
