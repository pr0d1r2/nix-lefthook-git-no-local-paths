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
2. All bats unit tests (`tests/unit/**/*.bats`) must pass in the CI devShell.
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
/Users/[a-zA-Z0-9._-]
/home/[a-zA-Z0-9._-]
/root/  # nolocalpath
/tmp/[a-zA-Z0-9._-]
```

### Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `LEFTHOOK_GIT_NO_LOCAL_PATHS_TIMEOUT` | `30` | Timeout (seconds) for the hook |
| `LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT` | `60` | Timeout for `nix flake check` hook |
| `LEFTHOOK_TAPLO_LINT_TIMEOUT` | `30` | Timeout for taplo TOML lint hook |
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
| `x` | T6 | Add bats test verifying that output includes filename and line number (`grep -HnE` format) |
| `x` | T7 | Widen `/tmp/` regex to also catch numeric-prefixed temp dirs (currently requires `[a-zA-Z]` after the slash) |
| `x` | T8 | Add `.envrc` `watch_file` entry for `config/lefthook/file_size_limits.yml` (used by file-size-check wrapper at runtime) |

## §B — Bugs / Known Issues

1. **`# nolocalpath` is greedy**: the suppression is a post-filter
   (`grep -v`), so it fires on any matching line that also contains the
   string `# nolocalpath` anywhere — including inside string literals or
   unrelated comments.
2. **2026-07-22 — Lint configurations drifted from their tested policy**:
   markdownlint and yamllint overrides were partially replaced by stricter
   defaults that the repository content does not follow. The expected rule
   overrides were restored without weakening or changing the tests.
3. **2026-07-22 — Agentic markdownlint executable missing from CI**:
   `lefthook.yml` invoked `lefthook-markdownlint-agentic`, but the CI dev shell
   did not package that executable. Its source input and wrapper were added,
   with a test that maps every configured hook executable to the dev shell.
4. **2026-07-23 — Referenced confirm app omitted fragment wrappers**:
   the consumer migration used the standard `confirm` app, whose isolated
   runtime omitted the hook executables required by the selected fragments.
   The consumer now supplies a confirm app with the materialization packages
   on its runtime path, so CI verifies coherence outside the development shell.
5. **2026-07-29 — Pin update pulled breaking set-and-setting rev**:
   `nix flake update` advanced `set-and-setting` to rev `d2fa92cc` which
   dropped the `lib` output (`mkConsumerFlake`, `materializationFor`).
   Pinned `set-and-setting` back to `d0196d19`, the last rev exposing `lib`.
6. **2026-07-29 — flake.lock exceeds file-size-check limit**:
   `flake.lock` grew to 120KB (212 nodes) due to transitive dependency
   duplication across `set-and-setting` fragments. The `.lock` extension
   limit of 65536 in `config/lefthook/file_size_limits.yml` was too low.
   Raised to 196608 (192KB).
7. **2026-08-04 — Flake manifest rejected output bindings**:
   The flake-manifest guard rejected the `let` bindings used by `outputs`.
   Inlined the consumer flake construction and used the recursive flake
   outputs for the confirm app.
8. **2026-08-04 — Lock graph duplicated nixpkgs**:
   The consumer's `set-and-setting` input retained a separate
   `nixpkgs-lock` edge, producing two locked nixpkgs nodes and failing the
   lock-graph guardrail. Made that input follow the root `nixpkgs-lock`.
9. **2026-08-04 — Flake source was not nixfmt-formatted**:
   The guardrails `nixfmt-check` rejected `flake.nix` after the consumer
   output and confirm-app changes. Reformatted the list, runtime-input, and
   nested-attribute layout with the repository's Nix formatter.
10. **2026-08-13 — Duplicate `nix-flake-check` hook after fragment assembly**:
   The `nix` fragment began supplying the hook while the repository-local
   fragment still defined it, producing invalid YAML and failing the
   guardrail fidelity and executability checks. Removed the duplicate
   repository-local definitions.
