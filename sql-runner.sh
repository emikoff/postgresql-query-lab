#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

CONTAINER=${SQL_RUNNER_CONTAINER:-postgres_query_lab}
DB_USER=${SQL_RUNNER_USER:-postgres}
DEFAULT_DB=${SQL_RUNNER_DB:-postgres}
MODEL_FILE=${SQL_RUNNER_MODEL:-$SCRIPT_DIR/database/init.sql}

declare -a PROJECT_IDS=(1 2 3 4 5 7 8 9 10)
declare -A PROJECT_DIR=(
    [1]='exercises/day00-basics'
    [2]='exercises/day01-set-operations'
    [3]='exercises/day02-joins'
    [4]='exercises/day03-dml'
    [5]='exercises/day04-snapshots'
    [7]='exercises/day05-indexes'
    [8]='exercises/day06-schema-design'
    [9]='exercises/day07-olap'
    [10]='exercises/day08-transactions'
)
declare -A PROJECT_NAME=(
    [1]='SQLB1 · Basics'
    [2]='SQLB2 · Set operations'
    [3]='SQLB3 · Joins and CTE'
    [4]='SQLB4 · DML'
    [5]='SQLB5 · Snapshots'
    [7]='SQLB7 · Database indexes'
    [8]='SQLB8 · Schema design'
    [9]='SQLB9 · OLAP'
    [10]='SQLB10 · Isolation levels'
)
declare -A PROJECT_DAY=(
    [1]='day00' [2]='day01' [3]='day02' [4]='day03' [5]='day04'
    [7]='day05' [8]='day06' [9]='day07' [10]='day08'
)
declare -A PROJECT_MODE=(
    [1]='read-only' [2]='read-only' [3]='read-only' [4]='stateful'
    [5]='stateful' [7]='stateful' [8]='stateful' [9]='read-only'
    [10]='multi-session'
)

if [[ -t 1 && -z ${NO_COLOR:-} ]]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    GREEN='' RED='' YELLOW='' BLUE='' BOLD='' NC=''
fi

usage() {
    cat <<'EOF'
PostgreSQL Lab Runner

Usage:
  ./sql-runner.sh list
  ./sql-runner.sh status
  ./sql-runner.sh run <day|project> [exercise] [--fresh] [--yes]
  ./sql-runner.sh shell
  ./sql-runner.sh help

Examples:
  ./sql-runner.sh run 2
  ./sql-runner.sh run SQLB2 ex03
  ./sql-runner.sh run 8 ex06 --fresh
  ./sql-runner.sh run SQLB4 --yes

Environment overrides:
  SQL_RUNNER_CONTAINER  Docker container name
  SQL_RUNNER_USER       PostgreSQL user
  SQL_RUNNER_DB         persistent database
  SQL_RUNNER_MODEL      path to database initialization SQL
  NO_COLOR=1            disable ANSI colors

Notes:
  --fresh creates a temporary database, loads database/init.sql and removes the
  database after the run. For a selected exercise in a stateful project,
  all exercises from ex00 through the target are executed as prerequisites.
EOF
}

die() {
    printf '%bERROR:%b %s\n' "$RED" "$NC" "$*" >&2
    exit 1
}

resolve_project() {
    local requested=${1^^}
    requested=${requested#SQLB}
    requested=${requested#0}

    local id
    for id in "${PROJECT_IDS[@]}"; do
        if [[ $requested == "$id" || ${1^^} == SQLB"$id" ]]; then
            printf '%s\n' "$id"
            return 0
        fi
    done
    return 1
}

collect_files() {
    local id=$1
    local project_path=$SCRIPT_DIR/${PROJECT_DIR[$id]}
    local day=${PROJECT_DAY[$id]}

    [[ -d $project_path ]] || return 0
    find "$project_path" -mindepth 2 -maxdepth 2 -type f \
        -name "${day}_ex*.sql" -print0 | sort -z
}

count_files() {
    local count=0
    while IFS= read -r -d '' _; do
        ((count++))
    done < <(collect_files "$1")
    printf '%s\n' "$count"
}

list_projects() {
    printf '%-5s %-43s %-10s %-14s %s\n' 'ID' 'PROJECT' 'EXERCISES' 'MODE' 'STATUS'
    local id path count status
    for id in "${PROJECT_IDS[@]}"; do
        path=$SCRIPT_DIR/${PROJECT_DIR[$id]}
        count=$(count_files "$id")
        if [[ ! -d $path ]]; then
            status='missing'
        elif (( count == 0 )); then
            status='no SQL files'
        else
            status='ready'
        fi
        printf '%-5s %-43s %-10s %-14s %s\n' \
            "$id" "${PROJECT_NAME[$id]}" "$count" "${PROJECT_MODE[$id]}" "$status"
    done
}

require_docker() {
    command -v docker >/dev/null 2>&1 || die 'Docker is not installed or not in PATH.'
    [[ $(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null) == true ]] ||
        die "Container '$CONTAINER' is not running. Start compose.yml first."
}

require_postgres() {
    require_docker
    docker exec "$CONTAINER" pg_isready -U "$DB_USER" -d "$DEFAULT_DB" >/dev/null 2>&1 ||
        die "PostgreSQL in '$CONTAINER' is not ready."
}

show_status() {
    printf 'Container: %s\nDatabase:  %s\nUser:      %s\n' "$CONTAINER" "$DEFAULT_DB" "$DB_USER"
    require_postgres
    printf '%bStatus:    ready%b\n' "$GREEN" "$NC"
}

normalize_exercise() {
    local value=${1,,}
    value=${value#ex}
    [[ $value =~ ^[0-9]{1,2}$ ]] || return 1
    printf 'ex%02d\n' "$((10#$value))"
}

confirm_stateful_run() {
    local project=$1
    if [[ ! -t 0 ]]; then
        die "${project} changes database state. Re-run with --yes or --fresh."
    fi
    printf '%bWARNING:%b %s changes data or schema in database %s. Continue? [y/N] ' \
        "$YELLOW" "$NC" "$project" "$DEFAULT_DB" >&2
    local answer
    read -r answer
    [[ $answer =~ ^[Yy]$ ]] || die 'Run cancelled.'
}

FRESH_DB=''
cleanup_fresh_database() {
    if [[ -n $FRESH_DB ]]; then
        docker exec "$CONTAINER" psql -X -v ON_ERROR_STOP=1 -U "$DB_USER" -d postgres \
            -c "DROP DATABASE IF EXISTS \"$FRESH_DB\" WITH (FORCE);" >/dev/null 2>&1 || true
        FRESH_DB=''
    fi
}

create_fresh_database() {
    [[ -f $MODEL_FILE ]] || die "Model file not found: $MODEL_FILE"
    FRESH_DB="sql_runner_${1}_$$_$RANDOM"
    FRESH_DB=${FRESH_DB,,}
    trap cleanup_fresh_database EXIT INT TERM

    docker exec "$CONTAINER" psql -X -v ON_ERROR_STOP=1 -U "$DB_USER" -d postgres \
        -c "CREATE DATABASE \"$FRESH_DB\";" >/dev/null || die 'Cannot create temporary database.'
    docker exec -i "$CONTAINER" psql -X -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$FRESH_DB" \
        -f - < "$MODEL_FILE" >/dev/null || die 'Cannot load database/init.sql into temporary database.'
    printf '%bFresh database:%b %s\n' "$BLUE" "$NC" "$FRESH_DB"
}

execute_sql_file() {
    local file=$1 database=$2
    docker exec -i "$CONTAINER" psql \
        -X -a -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$database" \
        -P pager=off --pset border=2 -f - < "$file"
}

run_project() {
    local selector=${1:-}
    shift || true
    [[ -n $selector ]] || die 'Specify a day or project. See: sql-runner.sh list'

    local exercise='' fresh=0 assume_yes=0 argument
    for argument in "$@"; do
        case "$argument" in
            --fresh) fresh=1 ;;
            --yes|-y) assume_yes=1 ;;
            --*) die "Unknown option: $argument" ;;
            *)
                [[ -z $exercise ]] || die 'Only one exercise may be selected.'
                exercise=$(normalize_exercise "$argument") || die "Invalid exercise: $argument"
                ;;
        esac
    done

    local id
    id=$(resolve_project "$selector") || die "Unknown project: $selector"
    local project=${PROJECT_NAME[$id]}
    local mode=${PROJECT_MODE[$id]}
    local project_path=$SCRIPT_DIR/${PROJECT_DIR[$id]}

    [[ -d $project_path ]] || die "Project is missing: $project"
    [[ $mode != multi-session ]] || die "$project requires two interactive sessions and is not supported by run."

    local -a all_files=() selected_files=()
    mapfile -d '' -t all_files < <(collect_files "$id")
    (( ${#all_files[@]} > 0 )) || die "No SQL files found for $project (${PROJECT_DAY[$id]})."

    local file file_ex found=0
    if [[ -n $exercise ]]; then
        for file in "${all_files[@]}"; do
            file_ex=$(basename "$file")
            file_ex=${file_ex##*_}
            file_ex=${file_ex%.sql}
            if [[ $file_ex == "$exercise" ]]; then
                found=1
                selected_files+=("$file")
                break
            elif (( fresh )) && [[ $mode == stateful ]]; then
                selected_files+=("$file")
            fi
        done
        (( found )) || die "Exercise $exercise not found in $project."
    else
        selected_files=("${all_files[@]}")
    fi

    require_postgres
    local database=$DEFAULT_DB
    if (( fresh )); then
        create_fresh_database "$id"
        database=$FRESH_DB
    elif [[ $mode == stateful ]] && (( ! assume_yes )); then
        confirm_stateful_run "$project"
    fi

    printf '\n%bPostgreSQL Lab Runner%b\n' "$BOLD" "$NC"
    printf 'Project:   %s\nMode:      %s\nDatabase:  %s\nFiles:     %s\n\n' \
        "$project" "$mode" "$database" "${#selected_files[@]}"

    local total=${#selected_files[@]} passed=0 failed=0 started ended index=0
    started=$(date +%s)
    for file in "${selected_files[@]}"; do
        ((index++))
        printf '%b[%02d/%02d] RUN%b %s\n' "$BLUE" "$index" "$total" "$NC" "${file#"$SCRIPT_DIR"/}"
        if execute_sql_file "$file" "$database"; then
            ((passed++))
            printf '%b[%02d/%02d] PASS%b %s\n\n' "$GREEN" "$index" "$total" "$NC" "$(basename "$file")"
        else
            failed=1
            printf '%b[%02d/%02d] FAIL%b %s\n' "$RED" "$index" "$total" "$NC" "$(basename "$file")" >&2
            break
        fi
    done
    ended=$(date +%s)

    printf '%bResult:%b passed=%d failed=%d skipped=%d time=%ds\n' \
        "$BOLD" "$NC" "$passed" "$failed" "$((total - passed - failed))" "$((ended - started))"
    (( failed == 0 ))
}

open_shell() {
    require_postgres
    exec docker exec -it "$CONTAINER" psql -X -U "$DB_USER" -d "$DEFAULT_DB"
}

main() {
    local command=${1:-help}
    shift || true
    case "$command" in
        list) [[ $# -eq 0 ]] || die 'list does not accept arguments.'; list_projects ;;
        status) [[ $# -eq 0 ]] || die 'status does not accept arguments.'; show_status ;;
        run) run_project "$@" ;;
        shell) [[ $# -eq 0 ]] || die 'shell does not accept arguments.'; open_shell ;;
        help|-h|--help) usage ;;
        *) die "Unknown command: $command. See: sql-runner.sh help" ;;
    esac
}

main "$@"
