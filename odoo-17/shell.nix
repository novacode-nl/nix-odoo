##########################################################
# nixpkgs 22.05
#
# Use tarball instead of git, to speed up the store index!
##########################################################

# Instructions:
# https://lazamar.co.uk/nix-versions/?package=wkhtmltopdf&version=0.12.5&fullName=wkhtmltopdf-0.12.5&keyName=wkhtmltopdf&revision=f577872afb1bd17aa43419152230aabfc8c8d5bf&channel=nixos-20.03#instructions

{ pkgs ? import (builtins.fetchTarball {
  # url = "https://github.com/NixOS/nixpkgs/archive/a7ecde854aee5c4c7cd6177f54a99d2c1ff28a31.tar.gz";
  url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/23.05.tar.gz";
  sha256 = "10wn0l08j9lgqcw8177nh2ljrnxdrpri7bp0g7nvrsn9rkawvlbf";
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
    pkgs.python310Packages.libsass
    pkgs.python310Packages.pip
    # pkgs.python310Packages.pypdf2
    pkgs.python310Packages.python-ldap
    pkgs.python310Packages.setuptools
    pkgs.python310Packages.virtualenv
    # Python debuggers
    pkgs.python310Packages.ipdb
    pkgs.python310Packages.pyopenssl

    # PostgreSQL
    pkgs.postgresql_14
  ];

  shellHook = ''
    export PATH=result/local/bin:$PATH
  '';
}
