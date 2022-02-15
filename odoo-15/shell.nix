{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    # keep this line if you use bash
    pkgs.bashInteractive

    ########
    # odoo #
    ########

    # odoo deps for requirements.txt
    pkgs.cyrus_sasl.dev
    pkgs.gsasl
    pkgs.openldap

    # pkgs.poetry
    # pkgs.python38Packages.poetry
    pkgs.python38Packages.pip
    pkgs.python38Packages.setuptools
    pkgs.python38Packages.virtualenv

    pkgs.postgresql_13

    # See TODO in README
    # pkgs.wkhtmltopdf (12.5.0)
    
    #(pkgs.python38.withPackages (ps: [ ps.pypdf2 ])
    # propagatedBuildInputs = with pkgs.python38Packages; [ poetry ];
  ];
}
