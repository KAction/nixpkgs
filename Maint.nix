let
  pkgs = import ./. { };
in {
  tup = pkgs.pkgsStatic.tup;
}
