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

@test "file with Users path fails" {
    p="/User""s/john/projects/repo"
    printf 'url = "git+file://%s";\n' "$p" > "$TMP/bad.nix"
    run lefthook-git-no-local-paths "$TMP/bad.nix"
    assert_failure
}

@test "file with home path fails" {
    p="/home""/dev/src/project"
    printf 'path = "%s"\n' "$p" > "$TMP/bad.txt"
    run lefthook-git-no-local-paths "$TMP/bad.txt"
    assert_failure
}

@test "file with root path fails" {
    p="/root""/.config/app"
    printf 'dir = "%s"\n' "$p" > "$TMP/bad.txt"
    run lefthook-git-no-local-paths "$TMP/bad.txt"
    assert_failure
}

@test "nolocalpath comment suppresses detection" {
    p="/User""s/example/path"
    printf 'url = "%s"; # nolocalpath\n' "$p" > "$TMP/ok.nix"
    run lefthook-git-no-local-paths "$TMP/ok.nix"
    assert_success
}

@test "multiple files: one with local path causes failure" {
    p="/home""/user/stuff"
    printf 'clean content\n' > "$TMP/good.txt"
    printf 'path = "%s"\n' "$p" > "$TMP/bad.txt"
    run lefthook-git-no-local-paths "$TMP/good.txt" "$TMP/bad.txt"
    assert_failure
}
