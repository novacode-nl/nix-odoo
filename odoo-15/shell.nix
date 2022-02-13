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
    pkgs.python38Packages.poetry

    pkgs.postgresql_13

    # TODO: wkhtmltopdf (0.12.5)
    # https://lazamar.co.uk/nix-versions/?package=wkhtmltopdf&version=0.12.5&fullName=wkhtmltopdf-0.12.5&keyName=wkhtmltopdf&revision=f577872afb1bd17aa43419152230aabfc8c8d5bf&channel=nixos-20.03#instructions
    # pkgs.wkhtmltopdf
    
    #(pkgs.python38.withPackages (ps: [ ps.pypdf2 ])
    # propagatedBuildInputs = with pkgs.python38Packages; [ poetry ];
  ];
}
