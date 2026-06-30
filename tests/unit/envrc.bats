#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    ENVRC="$PROJECT_ROOT/.envrc"
}

@test ".envrc uses flake" {
    run grep -q '^use flake$' "$ENVRC"
    assert_success
}

@test ".envrc watches nix/lefthook-wrappers.nix" {
    run grep -q '^watch_file nix/lefthook-wrappers.nix$' "$ENVRC"
    assert_success
}

@test ".envrc watches nix/lefthook-nix-no-embedded-shell-scanner.sh" {
    run grep -q '^watch_file nix/lefthook-nix-no-embedded-shell-scanner.sh$' "$ENVRC"
    assert_success
}

@test ".envrc watches dev.sh" {
    run grep -q '^watch_file dev.sh$' "$ENVRC"
    assert_success
}

@test ".envrc watches lefthook-git-no-local-paths.sh" {
    run grep -q '^watch_file lefthook-git-no-local-paths.sh$' "$ENVRC"
    assert_success
}

@test ".envrc watches config/lefthook/file_size_limits.yml" {
    run grep -q '^watch_file config/lefthook/file_size_limits.yml$' "$ENVRC"
    assert_success
}
