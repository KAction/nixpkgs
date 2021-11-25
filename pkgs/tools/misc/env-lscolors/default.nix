{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "env-lscolors";
  version = "unstable-2022-05-05"; # upstream don't do releases

  src = fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "e36eebfb3e1b39497c6038cdc70c75109b6434de";
    sha256 = "sha256-KsVuHBd4CzAWDeobS0N4NW+z1KMK1kBnZg14g67SCeQ=";
  };

  installPhase = ''
    mkdir -p $out/share/lscolors
    cp LS_COLORS $out/share/lscolors/LS_COLORS
    dircolors -b LS_COLORS > $out/share/lscolors/lscolors.sh
  '';

  meta = with lib; {
    description = "Coloring configuration for GNU ls for many filetypes";
    homepage = "https://github.com/trapd00r/LS_COLORS";
    license = licenses.artistic2;
    maintainers = with maintainers; [ kaction ];
    platforms = platforms.all;
  };
}
