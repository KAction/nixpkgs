{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "incbin";
  version = "unstable-2021-10-06";

  src = fetchFromGitHub {
    owner = "graphitemaster";
    repo = "incbin";
    rev = "6e576cae5ab5810f25e2631f2e0b80cbe7dc8cbf";
    hash = "sha256-9YK1fy+NOJH8glSfiq2sy+Xcqda1SgT6YpxSKjBgFVI=";
  };

  # Upstream does not provide standard Makefile for install phase.
  installPhase = ''
    install -D -m 644 -T incbin.h  $out/include/incbin.h
    install -D -m 644 -T README.md $out/share/doc/incbin/README.md
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    make incbin
    make -C test test
    runHook postCheck
  '';

  meta = {
    description = "Library to include binary and text files into C/C++ code";
    homepage = "https://github.com/graphitemaster/incbin";
    license =  lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ kaction ];
    platforms = lib.platforms.unix;
  };
}
