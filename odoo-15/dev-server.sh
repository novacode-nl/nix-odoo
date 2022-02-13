#!/usr/bin/env bash

set -euo pipefail

kill_jobs() {
    jobs -p | xargs -rn1 kill
}

trap "kill_jobs" EXIT

ROOT=$(cd $(dirname -- "$0") && pwd)
PG="${ROOT}/postgres"
PGDATA="${PG}/data"

# Only listen on socket.
# So port 5432 won't clash with other servers)
START_POSTGRES="postgres -c unix_socket_directories=${PG} -c listen_addresses="

DB_NAME=postgres
DB_USER=odoo
SKIP_INIT_SCHEMA=${SKIP_INIT_SCHEMA:-}


postgres_start() {
    local DATADIR=${1:-$PGDATA}
    $START_POSTGRES -D "$DATADIR"
}

command_psql() {
    psql -h "$PG" -U "${DB_USER}" -d "${DB_NAME}" "$@"
}

await_postgres() {
    for n in $(seq 20); do
        if pg_isready -h "${PG}" -U "${DB_USER}" -d "${DB_NAME}" > /dev/null; then
            return 0
        else
            sleep 1
            echo -n .
        fi
    done

    echo "ERROR: PostgreSQL server failed to start up" >/dev/stderr
    exit 1
}

postgres_init() {
    local PGDATA_NEW="${PGDATA}.new"
    rm -rf "$PGDATA_NEW"
    pg_ctl -s init -D "$PGDATA_NEW" -o "-E UTF-8 --no-locale -A trust"
    echo "${PGDATA_NEW}"
    #rm -f "${PGDATA_NEW}/postgresql.conf"
    ls "${PG}"
    #ln -s "${PG}/postgresql.conf" "${PGDATA_NEW}/"

    postgres --single -D "$PGDATA_NEW" postgres < "${PG}/../data/prepare.sql" >/dev/null

    if [ ! "$SKIP_INIT_SCHEMA" ]; then
        $START_POSTGRES -D "$PGDATA_NEW" &
        await_postgres
        kill $!
        wait $! || true >/dev/null
    fi

    mv "$PGDATA_NEW" "$PGDATA"
    sync
}

command_purge() {
    rm -rf -- "$PGDATA"
    rm -rf "${PG}"/.s.PGSQL.*
}

command_postgres_init() {
    PGDATA="${1:-$PGDATA}"
    [ -d  "$PGDATA" ] || postgres_init
}

command_postgres() {
    PGDATA="${1:-$PGDATA}"
    [ -d  "$PGDATA" ] || postgres_init
    postgres_start
}

command_with_postgres() {
    # NOTE: Not calling command_postgres directly here because
    # backgrounding a function like that doesn't seem to have the same
    # effect (the EXIT trap doesn't work properly). That trap
    # (installed at the beginning of the script) takes care of
    # shutting down the PostgreSQL server at exit.
    $ROOT/bin/dev-server postgres &
    await_postgres
    "$@"
}

COMMAND="${1:-}"
[ -n "$COMMAND" ] && shift

case "$COMMAND" in
    install)
        # lorri shell
        command_postgres_init
        poetry install
	# poetry run python -m pip install --upgrade pip &
	# poetry run pip install -U -r addons/requirements.txt
        ;;
    start)
        # Also separate commands: poetry install, odoo shell
        command_postgres &
        poetry run ./odoo/odoo-bin -c odoo.conf
        ;;
    shell)
        poetry run ./odoo/odoo-bin shell -c odoo.conf
        ;;
    postgres)
        command_postgres "$@"
        ;;
    psql)
        command_psql "$@"
        ;;
    pg_dump)
        command_pg_dump "$@"
        ;;
    purge)
        command_purge
        ;;
    dump-schema)
        command_dump_schema "$@"
        ;;
    await_postgres)
        await_postgres "$@"
	;;
    with_postgres)
        command_with_postgres "$@"
	;;
    *)
        echo "Available commands:"
        echo "  start "
        echo "      Starts the development webserver (and the database server)"
        echo "  psql"
        echo "      Starts a psql shell (postgres server must already be running)"
        echo "  postgres"
        echo "      Starts just the postgres server (useful for backend development)"
        echo "  await_postgres"
        echo "      Wait (with timeout) until the postgres server is available (useful for CI mostly)"
        echo "  with_postgres"
        echo "      Starts the postgres server and executes runs the remaining arguments as a command line."
        echo "      The postgres server is shut down again once that command line terminates."
        echo "       Preserves the exit code of the command line."
        echo "  dump-schema"
        echo "      Update the schema.sql file with the current database state"
        echo "  purge"
        echo "      Completely drop the database files on disk"

esac
