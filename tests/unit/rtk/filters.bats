#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    PROJECT_ROOT="$BATS_TEST_DIRNAME/../../.."
    FILTERS="$PROJECT_ROOT/.rtk/filters.toml"
}

@test "has schema_version" {
    run grep '^schema_version' "$FILTERS"
    assert_success
}

@test "passes toml syntax check" {
    run taplo check "$FILTERS"
    assert_success
}
