{ config, lib, stdenv, fetchurl, zlib, lzo, libtasn1, nettle, pkgconfig, lzip
, perl, gmp, autoconf, autogen, automake, libidn, p11-kit, libiconv
, unbound, dns-root-data, gettext, cacert, util-linux
, guileBindings ? config.gnutls.guile or false, guile
, tpmSupport ? false, trousers, which, nettools, libunistring
, withSecurity ? false, Security  # darwin Security.framework
, autoreconfHook
}:

assert guileBindings -> guile != null;
let
  version = "3.6.15";

  # XXX: Gnulib's `test-select' fails on FreeBSD:
  # https://hydra.nixos.org/build/2962084/nixlog/1/raw .
  doCheck = !stdenv.isFreeBSD && !stdenv.isDarwin && lib.versionAtLeast version "3.4"
      && stdenv.buildPlatform == stdenv.hostPlatform;

  inherit (stdenv.hostPlatform) isDarwin;
in

stdenv.mkDerivation {
  name = "gnutls-${version}";
  inherit version;

  src = fetchurl {
    url = "mirror://gnupg/gnutls/v3.6/gnutls-${version}.tar.xz";
    sha256 = "0n0m93ymzd0q9hbknxc2ycanz49sqlkyyf73g9fk7n787llc7a0f";
  };

  outputs = [ "bin" "dev" "out" "man" "devdoc" ];
  # Not normally useful docs.
  outputInfo = "devdoc";
  outputDoc  = "devdoc";

  patches = [ ./nix-ssl-cert-file.patch ]
    # Disable native add_system_trust.
    ++ lib.optional (isDarwin && !withSecurity) ./no-security-framework.patch
    # fix gnulib tests on 32-bit ARM. Included on gnutls master.
    # https://lists.gnu.org/r/bug-gnulib/2020-08/msg00225.html
    ++ lib.optional stdenv.hostPlatform.isAarch32 ./fix-gnulib-tests-arm.patch;

  # Skip some tests:
  #  - pkgconfig: building against the result won't work before installing (3.5.11)
  #  - fastopen: no idea; it broke between 3.6.2 and 3.6.3 (3437fdde6 in particular)
  #  - trust-store: default trust store path (/etc/ssl/...) is missing in sandbox (3.5.11)
  #  - psk-file: no idea; it broke between 3.6.3 and 3.6.4
  # Change p11-kit test to use pkg-config to find p11-kit
  postPatch = lib.optionalString (lib.versionAtLeast version "3.4") ''
    sed '2iecho "name constraints tests skipped due to datefudge problems"\nexit 0' -i tests/cert-tests/name-constraints
  '' + lib.optionalString (lib.versionAtLeast version "3.6") ''
    sed '2iexit 77' -i tests/{pkgconfig,fastopen}.sh
    sed '/^void doit(void)/,/^{/ s/{/{ exit(77);/' -i tests/{trust-store,psk-file}.c
    sed 's:/usr/lib64/pkcs11/ /usr/lib/pkcs11/ /usr/lib/x86_64-linux-gnu/pkcs11/:`pkg-config --variable=p11_module_path p11-kit-1`:' -i tests/p11-kit-trust.sh
  '' + lib.optionalString stdenv.hostPlatform.isMusl '' # See https://gitlab.com/gnutls/gnutls/-/issues/945
    sed '2iecho "certtool tests skipped in musl build"\nexit 0' -i tests/cert-tests/certtool
  ''
  # For some reason libtool gets confused and tries to link static
  # library just built to libstdc++.so from gcc. Not essential.
  + lib.optionalString stdenv.hostPlatform.isStatic ''
    sed -ri -e '/ex[-_]cxx/ d' doc/examples/Makefile.am
  '';

  preConfigure = "patchShebangs .";
  configureFlags =
    lib.optional stdenv.isLinux "--with-default-trust-store-file=/etc/ssl/certs/ca-certificates.crt"
  ++ [
    "--disable-dependency-tracking"
    "--enable-fast-install"
    "--with-unbound-root-key-file=${dns-root-data}/root.key"
  ] ++ lib.optional guileBindings [
    "--enable-guile"
    "--with-guile-site-dir=\${out}/share/guile/site"
    "--with-guile-site-ccache-dir=\${out}/share/guile/site"
    "--with-guile-extension-dir=\${out}/share/guile/site"
  ] ++ lib.optional stdenv.hostPlatform.isStatic [
    "--without-p11-kit"
  ];

  enableParallelBuilding = true;

  buildInputs = [ lzo lzip libtasn1 libidn zlib gmp autogen libunistring unbound gettext libiconv ]
    ++ lib.optional (isDarwin && withSecurity) Security
    ++ lib.optional (tpmSupport && stdenv.isLinux) trousers
    # p11-kit does not support static build, which is reported by its
    # configure script.
    ++ lib.optional (!stdenv.hostPlatform.isStatic) p11-kit
    ++ lib.optional guileBindings guile;

  nativeBuildInputs = [ perl pkgconfig ]
    ++ lib.optionals stdenv.hostPlatform.isStatic [ autoreconfHook ]
    ++ lib.optionals (isDarwin && !withSecurity) [ autoconf automake ]
    ++ lib.optionals doCheck [ which nettools util-linux ];

  propagatedBuildInputs = [ nettle ];

  inherit doCheck;
  # stdenv's `NIX_SSL_CERT_FILE=/no-cert-file.crt` broke tests with:
  #   Error setting the x509 trust file: Error while reading file.
  checkInputs = [ cacert ];

  # Fixup broken libtool and pkgconfig files
  preFixup = lib.optionalString (!isDarwin) ''
    sed ${lib.optionalString tpmSupport "-e 's,-ltspi,-L${trousers}/lib -ltspi,'"} \
        -e 's,-lz,-L${zlib.out}/lib -lz,' \
        -e 's,-L${gmp.dev}/lib,-L${gmp.out}/lib,' \
        -e 's,-lgmp,-L${gmp.out}/lib -lgmp,' \
        -i $out/lib/*.la "$dev/lib/pkgconfig/gnutls.pc"
  '' + ''
    # It seems only useful for static linking but basically noone does that.
    substituteInPlace "$out/lib/libgnutls.la" \
      --replace "-lunistring" ""
  '';

  meta = with lib; {
    description = "The GNU Transport Layer Security Library";

    longDescription = ''
       GnuTLS is a project that aims to develop a library which
       provides a secure layer, over a reliable transport
       layer. Currently the GnuTLS library implements the proposed standards by
       the IETF's TLS working group.

       Quoting from the TLS protocol specification:

       "The TLS protocol provides communications privacy over the
       Internet. The protocol allows client/server applications to
       communicate in a way that is designed to prevent eavesdropping,
       tampering, or message forgery."
    '';

    homepage = "https://www.gnu.org/software/gnutls/";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ eelco fpletz ];
    platforms = platforms.all;
  };
}
