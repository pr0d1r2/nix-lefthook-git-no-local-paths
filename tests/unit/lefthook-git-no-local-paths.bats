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

@test "file with tmp path fails" {
    p="/tmp""/scratch/project"
    printf 'dir = "%s"\n' "$p" > "$TMP/bad.txt"
    run lefthook-git-no-local-paths "$TMP/bad.txt"
    assert_failure
}

@test "flake.lock local path: input fails" {
    p="/tmp""/nix-lefthook"
    printf '"path": "%s",\n        "type": "path"\n' "$p" > "$TMP/flake.lock"
    run lefthook-git-no-local-paths "$TMP/flake.lock"
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

@test "empty file passes" {
    touch "$TMP/empty.txt"
    run lefthook-git-no-local-paths "$TMP/empty.txt"
    assert_success
    assert_output ""
}

@test "binary file without local paths passes" {
    printf '\x00\x01\x02\x03\x04\x05' > "$TMP/binary.bin"
    run lefthook-git-no-local-paths "$TMP/binary.bin"
    assert_success
}

@test "binary file with embedded local path passes" {
    p="/home""/user/something"
    printf '\x00\x01%s\x00\x02' "$p" > "$TMP/binary_bad.bin"
    run lefthook-git-no-local-paths "$TMP/binary_bad.bin"
    assert_success
}

@test "file with only suppressed paths passes" {
    p1="/home""/dev/src"
    p2="/User""s/john/proj"
    {
        printf '%s # nolocalpath\n' "$p1"
        printf '%s # nolocalpath\n' "$p2"
    } > "$TMP/suppressed.txt"
    run lefthook-git-no-local-paths "$TMP/suppressed.txt"
    assert_success
    assert_output ""
}

@test "file with all four pattern types suppressed passes" {
    p1="/User""s/ann/work"
    p2="/home""/dev/src"
    p3="/root""/.config"
    p4="/tmp""/scratch"
    {
        printf '%s # nolocalpath\n' "$p1"
        printf '%s # nolocalpath\n' "$p2"
        printf '%s # nolocalpath\n' "$p3"
        printf '%s # nolocalpath\n' "$p4"
    } > "$TMP/all_suppressed.txt"
    run lefthook-git-no-local-paths "$TMP/all_suppressed.txt"
    assert_success
    assert_output ""
}

@test "file with mixed suppressed and unsuppressed paths fails" {
    p1="/home""/dev/src"
    p2="/User""s/john/proj"
    {
        printf '%s # nolocalpath\n' "$p1"
        printf '%s\n' "$p2"
    } > "$TMP/mixed.txt"
    run lefthook-git-no-local-paths "$TMP/mixed.txt"
    assert_failure
}

@test "file with numeric-prefixed tmp path fails" {
    p="/tmp""/123-build/output"
    printf 'dir = "%s"\n' "$p" > "$TMP/bad_tmp.txt"
    run lefthook-git-no-local-paths "$TMP/bad_tmp.txt"
    assert_failure
}

@test "file with numeric-prefixed tmp path suppressed passes" {
    p="/tmp""/42-cache/data"
    printf 'dir = "%s" # nolocalpath\n' "$p" > "$TMP/ok_tmp.txt"
    run lefthook-git-no-local-paths "$TMP/ok_tmp.txt"
    assert_success
}

@test "file with dot-prefixed tmp path fails" {
    p="/tmp""/.cache/build"
    printf 'dir = "%s"\n' "$p" > "$TMP/dot_tmp.txt"
    run lefthook-git-no-local-paths "$TMP/dot_tmp.txt"
    assert_failure
}

@test "file with dot-prefixed home path fails" {
    p="/home""/.local/share"
    printf 'dir = "%s"\n' "$p" > "$TMP/dot_home.txt"
    run lefthook-git-no-local-paths "$TMP/dot_home.txt"
    assert_failure
}

@test "file with dot-prefixed Users path fails" {
    p="/User""s/.hidden/project"
    printf 'dir = "%s"\n' "$p" > "$TMP/dot_users.txt"
    run lefthook-git-no-local-paths "$TMP/dot_users.txt"
    assert_failure
}

@test "file with numeric home username fails" {
    p="/home""/1000/documents"
    printf 'path = "%s"\n' "$p" > "$TMP/num_home.txt"
    run lefthook-git-no-local-paths "$TMP/num_home.txt"
    assert_failure
}

@test "file with numeric Users username fails" {
    p="/User""s/42/projects"
    printf 'path = "%s"\n' "$p" > "$TMP/num_users.txt"
    run lefthook-git-no-local-paths "$TMP/num_users.txt"
    assert_failure
}

@test "file with leading dash in name containing local path fails" {
    p="/home""/user/project"
    printf 'path = "%s"\n' "$p" > "$TMP/-dashed.txt"
    run bash -c 'cd "$1" && lefthook-git-no-local-paths -dashed.txt' -- "$TMP"
    assert_failure
}

@test "file with underscore-prefixed Users path fails" {
    p="/User""s/_www/sites"
    printf 'dir = "%s"\n' "$p" > "$TMP/underscore_users.txt"
    run lefthook-git-no-local-paths "$TMP/underscore_users.txt"
    assert_failure
}

@test "file with underscore-prefixed home path fails" {
    p="/home""/_service/app"
    printf 'dir = "%s"\n' "$p" > "$TMP/underscore_home.txt"
    run lefthook-git-no-local-paths "$TMP/underscore_home.txt"
    assert_failure
}

@test "file with underscore-prefixed tmp path fails" {
    p="/tmp""/_build/output"
    printf 'dir = "%s"\n' "$p" > "$TMP/underscore_tmp.txt"
    run lefthook-git-no-local-paths "$TMP/underscore_tmp.txt"
    assert_failure
}

@test "file with hyphen-prefixed tmp path fails" {
    p="/tmp""/-build/out"
    printf 'dir = "%s"\n' "$p" > "$TMP/hyphen_tmp.txt"
    run lefthook-git-no-local-paths "$TMP/hyphen_tmp.txt"
    assert_failure
}

@test "file with hyphen-prefixed home path fails" {
    p="/home""/-user/data"
    printf 'dir = "%s"\n' "$p" > "$TMP/hyphen_home.txt"
    run lefthook-git-no-local-paths "$TMP/hyphen_home.txt"
    assert_failure
}

@test "file with underscore-prefixed path suppressed passes" {
    p="/home""/_service/app"
    printf 'dir = "%s" # nolocalpath\n' "$p" > "$TMP/ok_underscore.txt"
    run lefthook-git-no-local-paths "$TMP/ok_underscore.txt"
    assert_success
}

@test "output includes filename and line number in grep -HnE format" {
    p="/home""/user/project"
    printf 'clean line\npath = "%s"\n' "$p" > "$TMP/format_check.txt"
    run lefthook-git-no-local-paths "$TMP/format_check.txt"
    assert_failure
    assert_line --partial "${TMP}/format_check.txt:2:"
}
