#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    WORKFLOW=".github/workflows/update-pins.yml"
    CI_WORKFLOW=".github/workflows/ci.yml"
}

@test "uses actions/checkout pinned to commit hash" {
    run grep 'uses: actions/checkout@' "$WORKFLOW"
    assert_success
    assert_output --partial '# v'
}

@test "checkout version matches ci.yml" {
    ci_version=$(grep 'actions/checkout@' "$CI_WORKFLOW" | head -1 | sed 's/.*actions\/checkout@//')
    pins_version=$(grep 'actions/checkout@' "$WORKFLOW" | head -1 | sed 's/.*actions\/checkout@//')
    assert_equal "$pins_version" "$ci_version"
}

@test "runs on ubuntu-latest" {
    run grep 'runs-on: ubuntu-latest' "$WORKFLOW"
    assert_success
}

@test "schedule runs daily" {
    run grep -A1 'schedule:' "$WORKFLOW"
    assert_success
    assert_output --partial 'cron:'
}

@test "has contents write permission" {
    run grep 'contents: write' "$WORKFLOW"
    assert_success
}

@test "has pull-requests write permission" {
    run grep 'pull-requests: write' "$WORKFLOW"
    assert_success
}

@test "uses cachix/install-nix-action pinned to commit hash" {
    run grep 'cachix/install-nix-action@' "$WORKFLOW"
    assert_success
    assert_output --partial '# v'
}

@test "runs nix flake update nixpkgs-lock" {
    run grep 'nix flake update nixpkgs-lock' "$WORKFLOW"
    assert_success
}

@test "runs nix flake check" {
    run grep 'nix flake check' "$WORKFLOW"
    assert_success
}

@test "uses peter-evans/create-pull-request pinned to commit hash" {
    run grep 'peter-evans/create-pull-request@' "$WORKFLOW"
    assert_success
    assert_output --partial '# v'
}

@test "triggers on workflow_dispatch" {
    run grep 'workflow_dispatch' "$WORKFLOW"
    assert_success
}
