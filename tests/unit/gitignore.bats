#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    GITIGNORE="$PROJECT_ROOT/.gitignore"
}

@test "ignores result directory" {
    run grep '^result$' "$GITIGNORE"
    assert_success
}

@test "ignores result-* directories" {
    run grep '^result-\*$' "$GITIGNORE"
    assert_success
}

@test "ignores .direnv directory" {
    run grep '^\.direnv$' "$GITIGNORE"
    assert_success
}
