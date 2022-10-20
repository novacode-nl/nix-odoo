##########################################################
# nixpkgs 20.03
#
# Use tarball instead of git, to speed up the store index!
##########################################################

# Instructions:
# https://lazamar.co.uk/nix-versions/?package=wkhtmltopdf&version=0.12.5&fullName=wkhtmltopdf-0.12.5&keyName=wkhtmltopdf&revision=f577872afb1bd17aa43419152230aabfc8c8d5bf&channel=nixos-20.03#instructions
{ pkgs ? import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/5272327b81ed355bbed5659b8d303cf2979b6953.tar.gz";
  sha256 = "162dywda2dvfj1248afxc45kcrg83appjd0nmdb541hl7rnncf02";
}) {} }:

pkgs.mkShell {
  buildInputs = [
    # keep this line if you use bash
    pkgs.bashInteractive

    # Odoo deps for requirements.txt
    pkgs.cyrus_sasl.dev
    pkgs.gsasl
    pkgs.libxml2
    pkgs.openldap
    pkgs.zlib

    # Python
    pkgs.python38Packages.libxml2
    pkgs.python38Packages.pip
    pkgs.python38Packages.setuptools
    pkgs.python38Packages.virtualenv

    # PostgreSQL
    pkgs.postgresql_13
  ];

  shellHook = ''
    export PATH=result/local/bin:$PATH
  '';
}
