# nix-odoo
Nix templates for Odoo development servers

## USAGE

(!) **After INSTALL**

**Start server (postgres, odoo)**

`$ ./dev-server.sh start`

**Other commands, just...**

`$ ./dev-server.sh`

**Example: psql**

`$ ./dev-server.sh psql`


## INSTALL (bootstrap)

1. git clone https://github.com/novacode-nl/nix-odoo

2. `$ cp -R nix-odoo/odoo-15 TARGET`

   Example:
   `$ cp -R nix-odoo/odoo-15 novacode-15`

3. `$ cd TARGET`

4. Edit odoo.conf
   - addons_path
   - db_host (absolute path to postgres socket-dir)
   - http_port
   - longpolling_port
   - Other dirs/files (geoip, screenshots)

5. Copy/add odoo (+ enterprise) dir

   Example:
   `$ git clone https://github.com/odoo/odoo.git --branch 15.0 --single-branch`

6. `$ lorri shell` (STILL NEEDED with direnv ?)
7. `$ ./dev-server.sh install`
8. `$ ./dev-server.sh start`


## FEATURES

- PostgreSQL listens (serves) from socket directory
- File `odoo-VERSION/pyproject.toml` (created from odoo `requirements.txt`)


## TODO

1. Unclutter the root-dir

```
   nix-odoo/
       .git # this git repo
       odoo-15/
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
   See file `shell.nix`

3. Generate `odoo-VERSION/pyproject.toml` from odoo `requirements.txt`
