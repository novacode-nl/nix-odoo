{ pkgs ? import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/a7ecde854aee5c4c7cd6177f54a99d2c1ff28a31.tar.gz";
  sha256 = "162dywda2dvfj1248afxc45kcrg83appjd0nmdb541hl7rnncf02";
}) {} }:

######################
# wkhtmltopdf (0.12.5)
######################
# Instructions:
# https://lazamar.co.uk/nix-versions/?package=wkhtmltopdf&version=0.12.5&fullName=wkhtmltopdf-0.12.5&keyName=wkhtmltopdf&revision=f577872afb1bd17aa43419152230aabfc8c8d5bf&channel=nixos-20.03#instructions
#
# Use tarball, instead of git, to speed up the store index!
let
  # Channel	nixos-20.03
  pkgs_20_03 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/f577872afb1bd17aa43419152230aabfc8c8d5bf.tar.gz";
    # wkhtmltopdf 0.12.6
    # url = "https://github.com/NixOS/nixpkgs/archive/f6cc8cb29a3909136af1539848026bd41276e2ac.tar.gz";
  }) {};
  # pkgs_20_03 = import (builtins.fetchGit {
  #   # Descriptive name to make the store path easier to identify
  #   name = "NixOs-20.03";
  #   url = "https://github.com/NixOS/nixpkgs/";
  #   ref = "refs/heads/nixos-20.03";
  #   rev = "f577872afb1bd17aa43419152230aabfc8c8d5bf";
  # }) {};
in pkgs.mkShell {
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
    pkgs.python39Packages.pip
    pkgs.python39Packages.setuptools
    pkgs.python39Packages.virtualenv

    pkgs.postgresql_13

    #(pkgs.python38.withPackages (ps: [ ps.pypdf2 ])
    # propagatedBuildInputs = with pkgs.python38Packages; [ poetry ];
  ];

  shellHook = ''
    export PATH=result/local/bin:$PATH
  '';
}
