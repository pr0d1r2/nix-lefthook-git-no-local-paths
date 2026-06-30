#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    MARKDOWNLINT="$PROJECT_ROOT/.markdownlint.yml"
}

@test "disables MD013 line length" {
    run grep 'MD013: false' "$MARKDOWNLINT"
    assert_success
}

@test "disables MD032 blanks around lists" {
    run grep 'MD032: false' "$MARKDOWNLINT"
    assert_success
}

@test "disables MD041 first line heading" {
    run grep 'MD041: false' "$MARKDOWNLINT"
    assert_success
}

@test "disables MD060" {
    run grep 'MD060: false' "$MARKDOWNLINT"
    assert_success
}
