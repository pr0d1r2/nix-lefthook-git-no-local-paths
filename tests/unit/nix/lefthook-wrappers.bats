#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../../.."
    WRAPPERS="$PROJECT_ROOT/nix/lefthook-wrappers.nix"
    FLAKE="$PROJECT_ROOT/flake.nix"
}

@test "takes pkgs and inputs arguments" {
    run grep '{ pkgs, inputs }:' "$WRAPPERS"
    assert_success
}

@test "defines wrap helper" {
    run grep 'wrap =' "$WRAPPERS"
    assert_success
}

@test "wrap uses readFile not inline shell" {
    run grep 'builtins.readFile' "$WRAPPERS"
    assert_success
}

@test "every flake lefthook input has a wrapper" {
    inputs=$(grep 'nix-lefthook-.*-src' "$FLAKE" | grep 'url =' | sed 's/.*nix-lefthook-//' | sed 's/-src.*//' | sort)
    for input in $inputs; do
        run grep -q "nix-lefthook-${input}-src" "$WRAPPERS"
        assert_success
    done
}

@test "no embedded shell text assignments" {
    run bash -c "grep -c 'text = \"' '$WRAPPERS'"
    assert_failure
}

@test "nix-no-embedded-shell wrapper uses replaceStrings for scanner path" {
    run grep 'replaceStrings' "$WRAPPERS"
    assert_success
    run grep '@SCANNER_PATH@' "$WRAPPERS"
    assert_success
}

@test "passes nix syntax check" {
    run nix-instantiate --parse "$WRAPPERS"
    assert_success
}
