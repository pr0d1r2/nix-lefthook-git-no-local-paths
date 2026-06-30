#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    EDITORCONFIG="$PROJECT_ROOT/.editorconfig"
}

@test "root is set to true" {
    run grep '^root = true' "$EDITORCONFIG"
    assert_success
}

@test "default end_of_line is lf" {
    run bash -c "sed -n '/^\[\*\]$/,/^\[/p' '$EDITORCONFIG' | grep 'end_of_line = lf'"
    assert_success
}

@test "default insert_final_newline is true" {
    run bash -c "sed -n '/^\[\*\]$/,/^\[/p' '$EDITORCONFIG' | grep 'insert_final_newline = true'"
    assert_success
}

@test "default trim_trailing_whitespace is true" {
    run bash -c "sed -n '/^\[\*\]$/,/^\[/p' '$EDITORCONFIG' | grep 'trim_trailing_whitespace = true'"
    assert_success
}

@test "default charset is utf-8" {
    run bash -c "sed -n '/^\[\*\]$/,/^\[/p' '$EDITORCONFIG' | grep 'charset = utf-8'"
    assert_success
}

@test "default indent_style is space" {
    run bash -c "sed -n '/^\[\*\]$/,/^\[/p' '$EDITORCONFIG' | grep 'indent_style = space'"
    assert_success
}

@test "default indent_size is 2" {
    run bash -c "sed -n '/^\[\*\]$/,/^\[/p' '$EDITORCONFIG' | grep 'indent_size = 2'"
    assert_success
}

@test "markdown indent_size is unset" {
    run bash -c "sed -n '/^\[\*\.md\]$/,/^\[/p' '$EDITORCONFIG' | grep 'indent_size = unset'"
    assert_success
}

@test "bats indent_size is 4" {
    run bash -c "sed -n '/^\[\*\.bats\]$/,/^\[/p' '$EDITORCONFIG' | grep 'indent_size = 4'"
    assert_success
}
