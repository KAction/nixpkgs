let
  pkgs = import ./patched.nix { };
in {
  tup = pkgs.pkgsStatic.tup;

  inherit (pkgs.pkgsStatic) mutt;
  inherit (pkgs.pkgsStatic) w3m;
}
