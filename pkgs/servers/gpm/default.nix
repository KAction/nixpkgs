{ lib, stdenv, fetchurl, automake, autoconf, libtool, flex, bison, texinfo, fetchpatch

# Optional Dependencies
, ncurses ? null
}:

stdenv.mkDerivation rec {
  name = "gpm-1.20.7";

  src = fetchurl {
    url = "https://www.nico.schottelius.org/software/gpm/archives/${name}.tar.bz2";
    sha256 = "13d426a8h403ckpc8zyf7s2p5rql0lqbg2bv0454x0pvgbfbf4gh";
  };

  postPatch = ''
    substituteInPlace src/prog/gpm-root.y --replace __sigemptyset sigemptyset
  '';

  nativeBuildInputs = [ automake autoconf libtool flex bison texinfo ];
  buildInputs = [ ncurses ];

  hardeningDisable = [ "format" ];

  patches = [
    # musl compat patches, safe everywhere
    (fetchpatch {
      url = "https://raw.githubusercontent.com/gentoo/musl/5aed405d87dfa92a5cab1596f898e9dea07169b8/sys-libs/gpm/files/gpm-1.20.7-musl-missing-headers.patch";
      sha256 = "1g338m6j1sba84wlqp1r6rpabj5nm6ki577hjalg46czg0lfp20h";
    })
    # Touches same code as glibc fix in postPatch above, but on the non-glibc route
    (fetchpatch {
      url = "https://raw.githubusercontent.com/gentoo/musl/5aed405d87dfa92a5cab1596f898e9dea07169b8/sys-libs/gpm/files/gpm-1.20.7-musl-portable-sigaction.patch";
      sha256 = "0hfdqm9977hd5dpzn05y0a6jbj55w1kp4hd9gyzmg9wslmxni4rg";
    })
    (fetchpatch {
      url = "https://raw.githubusercontent.com/gentoo/musl/5aed405d87dfa92a5cab1596f898e9dea07169b8/sys-libs/gpm/files/gpm-1.20.7-sysmacros.patch";
      sha256 = "0lg4l9phvy2n8gy17qsn6zn0qq52vm8g01pgq5kqpr8sd3fb21c2";
    })
  ];

  preConfigure = with stdenv; ''
    ./autogen.sh
  ''
  # Upstream does not use Automake and write Makefile.in manually. Of
  # course, they forgot to handle --disable-shared case.
  #
  # Also we now need to fix build of example programs, which must be
  # linked with src/lib/libgpm.a
  + lib.optionalString hostPlatform.isStatic ''
    sed -i 's#SHLIB=libgpm.so#SHLIB=#' configure
    sed -i 's#lib/libgpm.so.@abi_lev@##' src/Makefile.in

    sed -i 's#prog/%.o$#prog/%.o lib/libgpm.a#' src/Makefile.in
    echo 'prog/gpm-root: LIBS += lib/libgpm.a' >> src/Makefile.in
    echo 'prog/mouse-test: LIBS += lib/libgpm.a' >> src/Makefile.in

  ''
  # Upstream build system does not support cross-compilation either,
  # assuming that unprefixed ar(1) is in PATH.
  + lib.optionalString (hostPlatform != buildPlatform) ''
    sed -i 's#= ar#= ${hostPlatform.config}-ar#' Makefile.include.in
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    (if ncurses == null then "--without-curses" else "--with-curses")
  ];

  # Provide libgpm.so for compatability
  postInstall = stdenv.lib.optionalString (!stdenv.hostPlatform.isStatic) ''
    ln -sv $out/lib/libgpm.so.2 $out/lib/libgpm.so
  '';

  meta = with lib; {
    homepage = "https://www.nico.schottelius.org/software/gpm/";
    description = "A daemon that provides mouse support on the Linux console";
    license = licenses.gpl2;
    platforms = platforms.linux ++ platforms.cygwin;
    maintainers = with maintainers; [ eelco ];
  };
}
