#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    LEFTHOOK="$PROJECT_ROOT/lefthook.yml"
}

@test "output includes failure" {
    run grep -A1 '^output:' "$LEFTHOOK"
    assert_success
    assert_output --partial 'failure'
}

@test "pre-commit runs in parallel" {
    run grep -A1 '^pre-commit:' "$LEFTHOOK"
    assert_success
    assert_output --partial 'parallel: true'
}

@test "pre-push runs in parallel" {
    run grep -A1 '^pre-push:' "$LEFTHOOK"
    assert_success
    assert_output --partial 'parallel: true'
}

@test "git-no-local-paths present in pre-commit" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep 'git-no-local-paths:'"
    assert_success
}

@test "git-no-local-paths present in pre-push" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep 'git-no-local-paths:'"
    assert_success
}

@test "nix-flake-check present in pre-commit" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep 'nix-flake-check:'"
    assert_success
}

@test "nix-flake-check present in pre-push" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep 'nix-flake-check:'"
    assert_success
}

@test "taplo-lint present in pre-commit" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep 'taplo-lint:'"
    assert_success
}

@test "taplo-lint present in pre-push" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep 'taplo-lint:'"
    assert_success
}

@test "all pre-commit commands use timeout" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep 'run:' | grep -v 'timeout'"
    assert_failure
}

@test "all pre-push commands use timeout" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep 'run:' | grep -v 'timeout'"
    assert_failure
}

@test "git-no-local-paths pre-commit uses staged_files" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep 'git-no-local-paths' | grep 'run:'"
    assert_success
    assert_output --partial '{staged_files}'
}

@test "git-no-local-paths pre-push uses push_files" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep 'git-no-local-paths' | grep 'run:'"
    assert_success
    assert_output --partial '{push_files}'
}

@test "nix-flake-check scoped to nix files" {
    run grep -B1 'nix flake check' "$LEFTHOOK"
    assert_success
    assert_output --partial '*.nix'
}

@test "taplo-lint scoped to toml files" {
    run grep -B1 'taplo check' "$LEFTHOOK"
    assert_success
    assert_output --partial '*.toml'
}

@test "taplo-lint pre-commit uses staged_files" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$LEFTHOOK' | grep 'taplo' | grep 'run:'"
    assert_success
    assert_output --partial '{staged_files}'
}

@test "taplo-lint pre-push uses all_files" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$LEFTHOOK' | grep 'taplo' | grep 'run:'"
    assert_success
    assert_output --partial '{all_files}'
}
