#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../../../.."
    LIMITS="$PROJECT_ROOT/config/lefthook/file_size_limits.yml"
}

@test "has default limit" {
    run grep '^default:' "$LIMITS"
    assert_success
}

@test "has extensions section" {
    run grep '^extensions:' "$LIMITS"
    assert_success
}

@test "lock files have higher limit than default" {
    default=$(grep '^default:' "$LIMITS" | awk '{print $2}')
    lock=$(grep '  lock:' "$LIMITS" | awk '{print $2}')
    [ "$lock" -gt "$default" ]
}

@test "md files have higher limit than default" {
    default=$(grep '^default:' "$LIMITS" | awk '{print $2}')
    md=$(grep '  md:' "$LIMITS" | awk '{print $2}')
    [ "$md" -gt "$default" ]
}

@test "covers nix extension" {
    run grep '  nix:' "$LIMITS"
    assert_success
}

@test "covers bats extension" {
    run grep '  bats:' "$LIMITS"
    assert_success
}

@test "covers yml extension" {
    run grep '  yml:' "$LIMITS"
    assert_success
}

@test "covers sh extension" {
    run grep '  sh:' "$LIMITS"
    assert_success
}
