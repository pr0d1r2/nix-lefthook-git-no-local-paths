#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    FLAKE="$PROJECT_ROOT/flake.nix"
}

@test "supports aarch64-darwin" {
    run grep 'aarch64-darwin' "$FLAKE"
    assert_success
}

@test "supports x86_64-darwin" {
    run grep 'x86_64-darwin' "$FLAKE"
    assert_success
}

@test "supports x86_64-linux" {
    run grep 'x86_64-linux' "$FLAKE"
    assert_success
}

@test "supports aarch64-linux" {
    run grep 'aarch64-linux' "$FLAKE"
    assert_success
}

@test "has default package output" {
    run grep 'packages = forAllSystems' "$FLAKE"
    assert_success
}

@test "has ci devShell" {
    run grep 'ci = pkgs.mkShell' "$FLAKE"
    assert_success
}

@test "has default devShell" {
    run grep 'default = pkgs.mkShell' "$FLAKE"
    assert_success
}

@test "default devShell includes gh" {
    run grep 'pkgs.gh' "$FLAKE"
    assert_success
}

@test "uses readFile for main script" {
    run grep 'builtins.readFile ./lefthook-git-no-local-paths.sh' "$FLAKE"
    assert_success
}

@test "uses readFile for dev shell hook" {
    run grep 'builtins.readFile ./dev.sh' "$FLAKE"
    assert_success
}

@test "sets BATS_LIB_PATH in devShell" {
    run grep 'BATS_LIB_PATH' "$FLAKE"
    assert_success
}

@test "passes nix syntax check" {
    run nix-instantiate --parse "$FLAKE"
    assert_success
}
