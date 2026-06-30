#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    WORKFLOW=".github/workflows/update-pins.yml"
    CI_WORKFLOW=".github/workflows/ci.yml"
}

@test "uses actions/checkout@v6" {
    run grep 'uses: actions/checkout@' "$WORKFLOW"
    assert_success
    assert_output --partial 'actions/checkout@v6'
}

@test "checkout version matches ci.yml" {
    ci_version=$(grep 'actions/checkout@' "$CI_WORKFLOW" | head -1 | sed 's/.*actions\/checkout@//')
    pins_version=$(grep 'actions/checkout@' "$WORKFLOW" | head -1 | sed 's/.*actions\/checkout@//')
    assert_equal "$pins_version" "$ci_version"
}
