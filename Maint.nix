let
  pkgs = import ./patched.nix { };
in {
  tup = pkgs.pkgsStatic.tup;

  inherit (pkgs) mutt;
}
