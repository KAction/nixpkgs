{ lib
, stdenv
, fetchurl
, writeText

, expat
, libX11
, libXau
, libXdmcp
, libXext
, libXft
, libXinerama
, libXrender

, patches ? [ ]
, conf ? null
}:

stdenv.mkDerivation rec {
  pname = "dwm";
  version = "6.4";

  src = fetchurl {
    url = "https://dl.suckless.org/dwm/${pname}-${version}.tar.gz";
    sha256 = "sha256-+pwNaaWESFB2z8GICf1wXlwggNr7E9XnKaNkbKdwOm4=";
  };

  buildInputs = [
    expat

    libX11
    libXau
    libXdmcp
    libXext
    libXft
    libXinerama
    libXrender
  ];

  prePatch = ''
    sed -i "s@/usr/local@$out@" config.mk
  '';

  # Allow users set their own list of patches
  inherit patches;

  # Allow users to set the config.def.h file containing the configuration
  postPatch =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf
        then conf else writeText "config.def.h" conf;
    in
    lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  preBuild = ''
    FREETYPELIBS='
      -lfontconfig
      -lXft
      -lXext
      -lXrender
      -lX11
      -lfreetype
      -lbz2
      -lxcb
      -lpng
      -lz
      -lXau
      -lXdmcp
      -lXft
      -lfontconfig
      -lbrotlidec
      -lbrotlicommon
      -lexpat
    '
    FREETYPELIBS=$(echo $FREETYPELIBS | tr '\n' ' ')
    makeFlagsArray=("CC=${stdenv.cc.targetPrefix}cc" FREETYPELIBS="$FREETYPELIBS")
  '';

  meta = with lib; {
    homepage = "https://dwm.suckless.org/";
    description = "An extremely fast, small, and dynamic window manager for X";
    longDescription = ''
      dwm is a dynamic window manager for X. It manages windows in tiled,
      monocle and floating layouts. All of the layouts can be applied
      dynamically, optimising the environment for the application in use and the
      task performed.
      Windows are grouped by tags. Each window can be tagged with one or
      multiple tags. Selecting certain tags displays all windows with these
      tags.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ viric neonfuz ];
    platforms = platforms.all;
  };
}
