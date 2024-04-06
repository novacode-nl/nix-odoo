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

postgres_start_listen() {
    local DATADIR=${1:-$PGDATA}
    postgres -c unix_socket_directories=${PG} -D "$DATADIR"
}

command_psql() {
    psql -h "$PG" -U "${DB_USER}" "$@"
}

command_psql_postgres() {
    psql -h "$PG" -U "${USER}" -d "${DB_NAME}" "$@"
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

command_postgres_listen() {
    PGDATA="${1:-$PGDATA}"
    [ -d  "$PGDATA" ] || postgres_init
    postgres_start_listen
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

command_virtualenv_create() {
    if [ ! -d ".venv" ]; then
	virtualenv .venv
    fi
}

command_pip_install_requirements() {
    # odoo/requirements.txt
    if [ -d odoo ] && [ -f odoo/requirements.txt ]; then
        echo "START: pip install -U -r odoo/requirements.txt"
        ./.venv/bin/pip install -U -r odoo/requirements.txt
        echo "DONE: pip install -U -r odoo/requirements.txt"
    else
        echo "ERROR: File odoo/requirements.txt not found."
    fi

    # addons/requirements.txt
    # addons/requirements.txt
    if [ -d addons ] && [ -f addons/requirements.txt ]; then
        echo "START: pip install -U -r addons/requirements.txt"
        ./.venv/bin/pip install -U -r addons/requirements.txt
        echo "DONE: pip install -U -r addons/requirements.txt"
    elif [ "$@" ]; then
        echo "START: pip install -U -r $@"
        ./.venv/bin/pip install -U -r "$@"
        echo "DONE: pip install -U -r $@"
    fi
}

command_pre_commit_install_hooks() {
    if [ -d addons ]; then
        echo "START: pre-commit install (Git pre-commit hooks) ..."
        cd addons
        for dir in */; do
            cd $dir
            echo ""
            echo "pre-commit install in Git checkout (dir): $dir"
            pre-commit install
            pre-commit install --hook-type commit-msg
            pre-commit autoupdate
            cd ..
        done;
        echo ""
        echo "DONE: pre-commit install (Git pre-commit hooks) ..."
    fi
}

COMMAND="${1:-}"
[ -n "$COMMAND" ] && shift

case "$COMMAND" in
    install)
	# lorri shell
	command_postgres_init
        command_pre_commit_install_hooks
	command_virtualenv_create
        command_pip_install_requirements
        ## poetry
	# poetry install
	# poetry run python -m pip install --upgrade pip &
	# poetry run pip install -U -r addons/requirements.txt
        ;;
    update)
        command_pre_commit_install_hooks
        command_pip_install_requirements
        ;;
    pip_install)
        command_pip_install_requirements "$@"
        ;;
    pre_commit_install)
        command_pre_commit_install_hooks
        ;;
    shell)
        command_postgres &
	.venv/bin/python ./odoo/odoo-bin shell -c odoo.conf -d $1
        ## poetry
        # poetry run ./odoo/odoo-bin shell -c odoo.conf
        ;;
    start)
        command_postgres &
	.venv/bin/python ./odoo/odoo-bin -c odoo.conf
        ## poetry
        # poetry run ./odoo/odoo-bin start -c odoo.conf
        ;;
    test)
        command_postgres &
	.venv/bin/python ./odoo/odoo-bin -c odoo.conf -d $1 --test-enable --stop-after-init -i "${@: 2}"
        pg_ctl -D "$PGDATA" stop
        ;;
    odoo_upgrade)
        command_postgres &
	.venv/bin/python ./odoo/odoo-bin -c odoo.conf -d $1 --stop-after-init -u "${@: 2}"
        ;;
    postgres)
        command_postgres "$@"
        ;;
    postgres_listen)
        command_postgres_listen "$@"
        ;;
    purge)
        command_purge
        ;;
    dump-schema)
        command_dump_schema "$@"
        ;;
    psql)
        command_psql "$@"
        ;;
    psql_postgres)
        command_psql_postgres "$@"
        ;;
    pg_dump)
        command_pg_dump "$@"
        ;;
    await_postgres)
        await_postgres "$@"
	;;
    with_postgres)
        command_with_postgres "$@"
	;;
    *)
        echo "Available commands:"
	echo "  install "
        echo "      Install/update: Nix shell, PostgreSQL, Python packages etc."
	echo "  pip_install "
        echo "      Install Python (pip) requirements."
        echo "      Commands executed (if requirements.txt file exist):"
        echo "      $ pip install -U -r odoo/requirements.txt"
        echo "      $ pip install -U -r addons/requirements.txt"
	echo "  pre_commit_install "
        echo "      Install pre-commit hooks (when present)."
        echo "      Commands executed when each Git addons repo clone has a .pre-commit-config.yaml file:"
        echo "      $ pre-commit install"
        echo "      $ pre-commit install --hook-type commit-msg"
        echo "      $ pre-commit autoupdate"
        echo "  shell "
        echo "      Starts the Odoo shell (Python repl) with the database server."
        echo "      First arg is a database."
        echo "      ./dev-server.sh shell DATABASE"
        echo "  start "
        echo "      Starts the Odoo server with the database server."
        echo "  test "
        echo "      Run tests."
        echo "      First arg is a database."
        echo "      Next args are module(s)."
        echo "      ./dev-server.sh test odoo_test module_1 module_2"
        echo "  odoo_upgrade "
        echo "      Upgrade Odoo module(s)."
        echo "      First arg is a database."
        echo "      Next arg is a comma-separated list of modules to update before running the server."
        echo "      ./dev-server.sh upgrade odoo_test module_1,module_2"
        echo "  psql"
        echo "      Starts a psql shell, requires databasename (postgres server must already be running)"
        echo "  psql_postgres"
        echo "      Starts a psql shell in postgres database (postgres server must already be running)"
        echo "  postgres"
        echo "      Starts just the postgres server (useful for backend development)"
        echo "  postgres_listen"
        echo "      Starts just the postgres server and listen on all addresses (useful for the upgrade.odoo.com script)"
        echo "  await_postgres"
        echo "      Wait (with timeout) until the postgres server is available (useful for CI mostly)"
        echo "  with_postgres"
        echo "      Starts the postgres server and executes runs the remaining arguments as a command line."
        echo "      The postgres server is shut down again once that command line terminates."
        echo "      Preserves the exit code of the command line."
        echo "  dump-schema"
        echo "      Update the schema.sql file with the current database state"
        echo "  purge"
        echo "      Completely drop the database files on disk"

esac
