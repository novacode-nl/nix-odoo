##########################################################
# nixpkgs 24.05
#
# Use tarball instead of git, to speed up the store index!
##########################################################

# Instructions:
# https://lazamar.co.uk/nix-versions/?package=wkhtmltopdf&version=0.12.5&fullName=wkhtmltopdf-0.12.5&keyName=wkhtmltopdf&revision=f577872afb1bd17aa43419152230aabfc8c8d5bf&channel=nixos-20.03#instructions

{ pkgs ? import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/24.05.tar.gz";
  #url = "https://github.com/NixOS/nixpkgs/archive/270dace49bc95a7f88ad187969179ff0d2ba20ed.tar.gz";
  #sha256 = "10wn0l08j9lgqcw8177nh2ljrnxdrpri7bp0g7nvrsn9rkawvlbf";
}) {} }:

pkgs.mkShell {
  buildInputs = [
    # keep this line if you use bash
    pkgs.bashInteractive

    # Git
    # pkgs.pre-commit

    # Odoo deps for requirements.txt
    pkgs.cyrus_sasl.dev
    pkgs.gsasl
    pkgs.openldap

    # Python
    pkgs.python312Packages.libsass
    # pkgs.python310Packages.pyopenssl
    pkgs.python312Packages.pip
    # pkgs.python310Packages.pypdf2
    # pkgs.python312Packages.python-ldap
    pkgs.python312Packages.setuptools
    pkgs.python312Packages.virtualenv
    # Python debuggers
    # pkgs.python312Packages.debugpy
    # pkgs.python312Packages.ipdb

    # PostgreSQL
    pkgs.postgresql_16

    # Required for VS Code extensions
    pkgs.stdenv.cc.cc.lib
  ];

  shellHook = ''
    export PATH=result/local/bin:$PATH
    # Required for VS Code extensions, when VS Code from nix shell
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc
  ]}
  '';
}
