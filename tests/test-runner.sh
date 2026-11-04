#!/usr/bin/env bash

set -uo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
RUNNER=$ROOT/sql-runner.sh
TEST_TMP=$(mktemp -d)
MOCK_BIN=$TEST_TMP/bin
MOCK_LOG=$TEST_TMP/docker.log
PASSED=0
FAILED=0

cleanup() {
    rm -rf "$TEST_TMP"
}
trap cleanup EXIT

mkdir -p "$MOCK_BIN"

cat > "$MOCK_BIN/docker" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$MOCK_DOCKER_LOG"
if [[ ${1:-} == inspect ]]; then
    echo true
    exit 0
fi
if [[ " $* " == *' pg_isready '* ]]; then
    exit 0
fi
if [[ " $* " == *' psql '* ]]; then
    cat >/dev/null
    exit "${MOCK_PSQL_EXIT:-0}"
fi
exit 0
EOF
chmod +x "$MOCK_BIN/docker"

run_runner() {
    env PATH="$MOCK_BIN:$PATH" \
        MOCK_DOCKER_LOG="$MOCK_LOG" \
        MOCK_PSQL_EXIT="${MOCK_PSQL_EXIT:-0}" \
        NO_COLOR=1 \
        "$RUNNER" "$@"
}

assert_success() {
    local name=$1
    shift
    if "$@" >"$TEST_TMP/output" 2>"$TEST_TMP/error"; then
        printf 'PASS: %s\n' "$name"
        ((PASSED++))
    else
        printf 'FAIL: %s\n' "$name"
        sed -n '1,80p' "$TEST_TMP/error"
        ((FAILED++))
    fi
}

assert_failure() {
    local name=$1
    shift
    if "$@" >"$TEST_TMP/output" 2>"$TEST_TMP/error"; then
        printf 'FAIL: %s\n' "$name"
        ((FAILED++))
    else
        printf 'PASS: %s\n' "$name"
        ((PASSED++))
    fi
}

assert_success 'help is available' run_runner help
assert_success 'project discovery works' run_runner list
grep -q 'SQLB5.*Snapshots.*missing' "$TEST_TMP/output" || { echo 'FAIL: missing project is not reported'; ((FAILED++)); }

assert_failure 'unknown project is rejected' run_runner run 6
assert_failure 'multi-session project is rejected' run_runner run 10
assert_success 'single read-only exercise runs' run_runner run 2 ex03
grep -q 'ON_ERROR_STOP=1' "$MOCK_LOG" || { echo 'FAIL: ON_ERROR_STOP is absent'; ((FAILED++)); }

MOCK_PSQL_EXIT=1
assert_failure 'psql error makes the run fail' run_runner run 2 ex03
unset MOCK_PSQL_EXIT

: > "$MOCK_LOG"
assert_success 'fresh stateful run includes prerequisites' run_runner run 8 ex03 --fresh
grep -q 'CREATE DATABASE' "$MOCK_LOG" || { echo 'FAIL: fresh database was not created'; ((FAILED++)); }
grep -q 'DROP DATABASE' "$MOCK_LOG" || { echo 'FAIL: fresh database was not removed'; ((FAILED++)); }
grep -q 'Files:     4' "$TEST_TMP/output" || { echo 'FAIL: prerequisites were not selected'; ((FAILED++)); }

assert_failure 'stateful persistent run requires confirmation' run_runner run 4

printf '\nResult: %d passed, %d failed\n' "$PASSED" "$FAILED"
(( FAILED == 0 ))
