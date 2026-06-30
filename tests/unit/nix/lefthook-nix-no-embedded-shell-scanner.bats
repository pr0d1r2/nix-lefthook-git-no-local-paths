#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    SCRIPT="nix/lefthook-nix-no-embedded-shell-scanner.sh"
    TMP="$BATS_TEST_TMPDIR"
}

@test "contains SCANNER_PATH placeholder" {
    run grep -c '@SCANNER_PATH@' "$SCRIPT"
    assert_success
}

@test "sets SCANNER after placeholder substitution" {
    sed 's|@SCANNER_PATH@|/nix/store/fake/scan-nix-no-embedded-shell.sh|' "$SCRIPT" > "$TMP/scanner.sh"
    run bash -c 'source "$1" && echo "$SCANNER"' -- "$TMP/scanner.sh"
    assert_success
    assert_output "/nix/store/fake/scan-nix-no-embedded-shell.sh"
}

@test "passes bash syntax check" {
    sed 's|@SCANNER_PATH@|/test/path|' "$SCRIPT" > "$TMP/scanner.sh"
    run bash -n "$TMP/scanner.sh"
    assert_success
}
