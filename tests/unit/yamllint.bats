#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    YAMLLINT="$PROJECT_ROOT/.yamllint.yml"
}

@test "extends default configuration" {
    run grep 'extends: default' "$YAMLLINT"
    assert_success
}

@test "disables truthy check-keys" {
    run grep 'check-keys: false' "$YAMLLINT"
    assert_success
}

@test "disables line-length rule" {
    run grep 'line-length: disable' "$YAMLLINT"
    assert_success
}
