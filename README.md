# nix-lefthook-git-no-local-paths

[![CI](https://github.com/pr0d1r2/nix-lefthook-git-no-local-paths/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-git-no-local-paths/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible local filesystem path detector, packaged as a Nix flake.

Detects hardcoded local paths (`/Users/`, `/home/`, `/root/`) in staged files to prevent leaking development environment details. Add `# nolocalpath` to a line to suppress the check. Exits 0 when no files are found or no local paths are detected.

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml`:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-git-no-local-paths
    ref: main
    configs:
      - lefthook-remote.yml
```

### Option B: Flake input

Add as a flake input:

```nix
inputs.nix-lefthook-git-no-local-paths = {
  url = "github:pr0d1r2/nix-lefthook-git-no-local-paths";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-git-no-local-paths.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Add to `lefthook.yml`:

```yaml
pre-commit:
  commands:
    git-no-local-paths:
      run: timeout ${LEFTHOOK_GIT_NO_LOCAL_PATHS_TIMEOUT:-30} lefthook-git-no-local-paths {staged_files}
```

### Configuring timeout

The default timeout is 30 seconds. Override per-repo via environment variable:

```bash
export LEFTHOOK_GIT_NO_LOCAL_PATHS_TIMEOUT=60
```

## Development

The repo includes an `.envrc` for [direnv](https://direnv.net/) — entering the directory automatically loads the devShell with all dependencies:

```bash
cd nix-lefthook-git-no-local-paths  # direnv loads the flake
bats tests/unit/
```

If not using direnv, enter the shell manually:

```bash
nix develop
bats tests/unit/
```

## License

MIT
