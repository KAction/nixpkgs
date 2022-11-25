let
  pkgs = import ./patched.nix { };
in {
  tup = pkgs.pkgsStatic.tup;
  inherit (pkgs) cachix;

  inherit (pkgs.pkgsStatic) xstow;
  inherit (pkgs.pkgsStatic) htop;
  inherit (pkgs.pkgsStatic) curl;
  inherit (pkgs.pkgsStatic) exa;
  inherit (pkgs.pkgsStatic) gnumake;
  inherit (pkgs.pkgsStatic) indent;
  inherit (pkgs.pkgsStatic) fish;
  inherit (pkgs.pkgsStatic) abduco;
  inherit (pkgs.pkgsStatic) mpop;
  inherit (pkgs.pkgsStatic) msmtp;
  inherit (pkgs.pkgsStatic) mutt;
  inherit (pkgs.pkgsStatic) nix;
  inherit (pkgs.pkgsStatic) w3m;
}
