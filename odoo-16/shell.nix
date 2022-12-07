##########################################################
# nixpkgs 22.05
#
# Use tarball instead of git, to speed up the store index!
##########################################################

# Instructions:
# https://lazamar.co.uk/nix-versions/?package=wkhtmltopdf&version=0.12.5&fullName=wkhtmltopdf-0.12.5&keyName=wkhtmltopdf&revision=f577872afb1bd17aa43419152230aabfc8c8d5bf&channel=nixos-20.03#instructions

{ pkgs ? import (builtins.fetchTarball {
  # url = "https://github.com/NixOS/nixpkgs/archive/a7ecde854aee5c4c7cd6177f54a99d2c1ff28a31.tar.gz";
  url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/22.05.tar.gz";
  sha256 = "162dywda2dvfj1248afxc45kcrg83appjd0nmdb541hl7rnncf02";
}) {} }:

pkgs.mkShell {
  buildInputs = [
    # keep this line if you use bash
    pkgs.bashInteractive

    # Odoo deps for requirements.txt
    pkgs.cyrus_sasl.dev
    pkgs.gsasl
    pkgs.openldap

    # Python
    pkgs.python39Packages.pip
    pkgs.python39Packages.setuptools
    pkgs.python39Packages.virtualenv
    # Python debuggers
    pkgs.python39Packages.ipdb
    pkgs.python39Packages.pyopenssl

    # PostgreSQL
    pkgs.postgresql_14
  ];

  shellHook = ''
    export PATH=result/local/bin:$PATH
  '';
}
