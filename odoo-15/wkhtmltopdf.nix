{ pkgs ? import <nixpkgs> {} }:

let
  pkgs_libjpeg_8d = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/19f768a97808da4c8700ae24513ab557801be12c.tar.gz";
  }) {};

in pkgs.stdenv.mkDerivation rec {
  name = "wkhtmltopdf";

  src = pkgs.fetchurl {
    url = "https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb";
    sha256 = "sha256-20j6GgQzCcS/6Mjg443AbBg/ghWZ3YjU486kfFpdTNM=";
  };

  unpackCmd = "${pkgs.dpkg}/bin/dpkg-deb -x $curSrc .";

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
  ];

  buildInputs = [
    pkgs_libjpeg_8d.libjpeg_original
    pkgs.freetype
    pkgs.xorg.libX11
    pkgs.xorg.libXrender
    pkgs.openssl
    pkgs.fontconfig
    # libstdc++
    pkgs.stdenv.cc.cc.lib
  ];

  # see https://nixos.org/nixpkgs/manual/#ssec-install-phase
  # $src is defined as the location of our `src` attribute above
  installPhase = ''
    # $out is an automatically generated filepath by nix,
    # but it's up to you to make it what you need. We'll create a directory at
    # that filepath, then copy our sources into it.
    mkdir $out
    cp -rv . $out/
  '';
}
