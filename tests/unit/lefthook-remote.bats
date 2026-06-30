#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../.."
    REMOTE="$PROJECT_ROOT/lefthook-remote.yml"
}

@test "git-no-local-paths present in pre-commit" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$REMOTE' | grep 'git-no-local-paths:'"
    assert_success
}

@test "git-no-local-paths present in pre-push" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$REMOTE' | grep 'git-no-local-paths:'"
    assert_success
}

@test "pre-commit uses staged_files" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$REMOTE' | grep 'run:'"
    assert_success
    assert_output --partial '{staged_files}'
}

@test "pre-push uses push_files" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$REMOTE' | grep 'run:'"
    assert_success
    assert_output --partial '{push_files}'
}

@test "pre-commit command uses timeout" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' '$REMOTE' | grep 'run:' | grep -v 'timeout'"
    assert_failure
}

@test "pre-push command uses timeout" {
    run bash -c "sed -n '/^pre-push:/,\$p' '$REMOTE' | grep 'run:' | grep -v 'timeout'"
    assert_failure
}
