#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    WORKFLOW=".github/workflows/ci.yml"
}

@test "uses actions/checkout@v7" {
    run grep 'uses: actions/checkout@' "$WORKFLOW"
    assert_success
    assert_output --partial 'actions/checkout@v7'
}

@test "linux job runs on ubuntu-latest" {
    run grep -A1 'build-linux:' "$WORKFLOW"
    assert_success
    assert_output --partial 'ubuntu-latest'
}

@test "macos job runs on macos-latest" {
    run grep -A2 'build-macos:' "$WORKFLOW"
    assert_success
    assert_output --partial 'macos-latest'
}

@test "macos job only runs on push or workflow_dispatch" {
    run grep -A1 'build-macos:' "$WORKFLOW"
    assert_success
    assert_output --partial "if:"
}

@test "both jobs use same CI action pin" {
    linux_pin=$(grep 'nix-lefthook-ci-action@' "$WORKFLOW" | head -1 | sed 's/.*nix-lefthook-ci-action@//')
    macos_pin=$(grep 'nix-lefthook-ci-action@' "$WORKFLOW" | tail -1 | sed 's/.*nix-lefthook-ci-action@//')
    assert_equal "$linux_pin" "$macos_pin"
}

@test "both jobs use same checkout version" {
    linux_ver=$(grep 'actions/checkout@' "$WORKFLOW" | head -1 | sed 's/.*actions\/checkout@//')
    macos_ver=$(grep 'actions/checkout@' "$WORKFLOW" | tail -1 | sed 's/.*actions\/checkout@//')
    assert_equal "$linux_ver" "$macos_ver"
}

@test "triggers on push to main" {
    run grep -A2 'push:' "$WORKFLOW"
    assert_success
    assert_output --partial 'main'
}

@test "triggers on pull_request to main" {
    run grep -A2 'pull_request:' "$WORKFLOW"
    assert_success
    assert_output --partial 'main'
}

@test "triggers on workflow_dispatch" {
    run grep 'workflow_dispatch' "$WORKFLOW"
    assert_success
}

@test "macos job sets flake-check-timeout" {
    run bash -c "sed -n '/build-macos:/,\$p' '$WORKFLOW' | grep 'flake-check-timeout'"
    assert_success
}
