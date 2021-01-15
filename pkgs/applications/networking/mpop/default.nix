{ lib, stdenv, fetchurl, pkgconfig, gnutls, gsasl, libidn, Security }:

with lib;

stdenv.mkDerivation rec {
  pname = "mpop";
  version = "1.4.11";

  src = fetchurl {
    url = "https://marlam.de/${pname}/releases/${pname}-${version}.tar.xz";
    sha256 = "1gcxvhin5y0q47svqbf90r5aip0cgywm8sq6m84ygda7km8xylwv";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ gnutls gsasl libidn ]
    ++ optional stdenv.isDarwin Security;

  # I searched generated ./configure script and it does not look like it
  # knows that sometimes pkg-config must be called with --static flag,
  # so let us force it as needed.
  preConfigure = optionalString stdenv.hostPlatform.isStatic ''
    PKG_CONFIG="$PKG_CONFIG --static"
  '';

  configureFlags = optional stdenv.isDarwin [ "--with-macosx-keyring" ];

  meta = {
      description = "POP3 mail retrieval agent";
      homepage = "https://marlam.de/mpop";
      license = licenses.gpl3Plus;
      platforms = platforms.unix;
    };
}
