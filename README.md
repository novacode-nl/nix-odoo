# nix-odoo
Nix templates for Odoo development servers

## USAGE

(!) **After INSTALL**

**Start server (postgres, odoo)**

`$ ./dev-server.sh start`

When you want to import a database which takes a long time, use:

`$ ./dev-server.sh start --limit-time-real=-1`

This ensures the importer won't be killed for taking too long.

**Other commands, just...**

`$ ./dev-server.sh`

**Example: psql**

`$ ./dev-server.sh psql`


## INSTALL (bootstrap)

1. git clone https://github.com/novacode-nl/nix-odoo

2. `$ cp -R nix-odoo/odoo-VERSION TARGET`

    Where `VERSION` represents the Odoo version.

   Example:
   `$ cp -R nix-odoo/odoo-VERSION novacode-VERSION`

3. `$ cd TARGET`

4. Edit odoo.conf
   - addons_path
   - db_host (absolute path to postgres socket-dir)
   - http_port
   - longpolling_port
   - Other dirs/files (geoip, screenshots)

5. Add odoo (+ enterprise) dir

   Example:
   `$ git clone https://github.com/odoo/odoo.git --branch 16.0 --depth 1`

6. Add project AKA addons dir

    **The `dev-server.sh` script expects this as directory name `addons`.**

    Example:
   `$ git clone https://github.com/novacode-nl/novacode.git --branch 16.0 addons`

7. (Optional) Add Git**pre-commit (i)** and **Gitlint (ii)** config files into the addons directory

    (i) pre-commit framework:
    - https://pre-commit.com

    (ii) Gitlint (Git commit message linter):
    - https://jorisroovers.com/gitlint/latest/
    - https://github.com/jorisroovers/gitlint

    Example, copy from examples:

```
cp ../odoo-VERSION/pre-commit_EXAMPLES/.gitlint_EXAMPLE ./addons/.gitlint
cp ../odoo-VERSION/pre-commit_EXAMPLES/.pre-commit-config.yaml_EXAMPLE ./addons/.pre-commit-config.yaml
```

8. `$ nix-build wkhtmltopdf.nix`
9. `$ ./dev-server.sh install`
10. `$ ./dev-server.sh start`


## FEATURES

- PostgreSQL listens (serves) from socket directory
- File `odoo-VERSION/pyproject.toml` (created from odoo `requirements.txt`)

## UPGRADE - upgrade.odoo.com

#### Filestore preparation

The upgrade script expects the old filestore located under the OS user it's `~/.local/share/Odoo/filestore/DB_NAME` directory.
So copy the filestore into that directory with same database name (`DB_NAME`).

#### PostgreSQL preparation

Having PostgreSQL running on a Unix socket causes issues with Odoo's upgrade script.\
The upgrade script excepts PostgreSQL connection at `/run/postgresql/.s.PGSQL.5432`.

**Current workaround**

_**Terminal (tty) 1**_

```
cd nix-odoo/TARGET
./dev-server postgres_tcp
```

_**Terminal (tty) 2**_

```
sudo su
mkdir /run/postgresql
ln -s nix-odoo/TARGET/postgres/.s.PGSQL.5432 /run/postgresql/
```

#### Upgrade

Run it and follow output (logging)

`python <(curl -s https://upgrade.odoo.com/upgrade) test -d <your db name> -t <target version>`

### Post actions (TARGET)

1. Copy the migrated filestore directory into `nix-odoo/TARGET/data`.
2. Export dump (with filestore)
3. Restore dump in new version

## TODO

1. Unclutter the root-dir

```
   nix-odoo/
       .git # this git repo
       odoo-16/
           # will become a git repo, eg. to share
           .gitignore # odoo, postgres, data (liquid dirs, files)
           dev-server.sh
           pyproject.toml
           README.md
           shell.nix
           odoo/
               odoo.conf
               addons/
                  .gitempty
               (odoo/)
               (enterprise/)
	   postgres/
               .gitempty
	   data/
               .gitempty
	   scripts/
               prepare.sql
```

2. wkhtmltopdf (0.12.5)
   See file `wkhtmltopdf.nix`

3. Generate `odoo-VERSION/pyproject.toml` from odoo `requirements.txt`
