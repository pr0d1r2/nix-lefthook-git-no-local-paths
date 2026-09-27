#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    FLAKE="$PROJECT_ROOT/flake.nix"
    CHECKS="$PROJECT_ROOT/nix/checks.nix"
    SYSTEMS="$PROJECT_ROOT/nix/systems.nix"
}

@test "supports aarch64-darwin" {
    run grep 'aarch64-darwin' "$SYSTEMS"
    assert_success
}

@test "supports x86_64-darwin" {
    run grep 'x86_64-darwin' "$SYSTEMS"
    assert_success
}

@test "supports x86_64-linux" {
    run grep 'x86_64-linux' "$SYSTEMS"
    assert_success
}

@test "supports aarch64-linux" {
    run grep 'aarch64-linux' "$SYSTEMS"
    assert_success
}

@test "uses readFile for main script" {
    run grep 'builtins.readFile ../lefthook-git-no-local-paths.sh' "$PROJECT_ROOT/nix/package.nix"
    assert_success
}

@test "passes nix syntax check" {
    run nix-instantiate --parse "$FLAKE"
    assert_success
}
