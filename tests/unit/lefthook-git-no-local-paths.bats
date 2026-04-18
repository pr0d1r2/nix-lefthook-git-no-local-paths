#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"
}

@test "no args exits 0" {
    run lefthook-git-no-local-paths
    assert_success
}

@test "non-existent file is skipped" {
    run lefthook-git-no-local-paths /nonexistent/file.txt
    assert_success
}

@test "file without local paths passes" {
    printf 'url = "github:pr0d1r2/repo";\n' > "$TMP/clean.nix"
    run lefthook-git-no-local-paths "$TMP/clean.nix"
    assert_success
}

@test "file with /Users/ path fails" {
    printf 'url = "git+file:///Users/john/projects/repo";\n' > "$TMP/bad.nix"
    run lefthook-git-no-local-paths "$TMP/bad.nix"
    assert_failure
}

@test "file with /home/ path fails" {
    printf 'path = "/home/dev/src/project"\n' > "$TMP/bad.txt"
    run lefthook-git-no-local-paths "$TMP/bad.txt"
    assert_failure
}

@test "file with /root/ path fails" {
    printf 'dir = "/root/.config/app"\n' > "$TMP/bad.txt"
    run lefthook-git-no-local-paths "$TMP/bad.txt"
    assert_failure
}

@test "nolocalpath comment suppresses detection" {
    printf 'url = "/Users/example/path"; # nolocalpath\n' > "$TMP/ok.nix"
    run lefthook-git-no-local-paths "$TMP/ok.nix"
    assert_success
}

@test "multiple files: one with local path causes failure" {
    printf 'clean content\n' > "$TMP/good.txt"
    printf 'path = "/home/user/stuff"\n' > "$TMP/bad.txt"
    run lefthook-git-no-local-paths "$TMP/good.txt" "$TMP/bad.txt"
    assert_failure
}
