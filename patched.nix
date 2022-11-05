args:
let
  overlay = self: super: {
    mutt = super.mutt.override {
      sslSupport = false;
      gpgSupport = false;
      gssSupport = false;
      headerCache = false;
      saslSupport = false;
      imapSupport = false;
      pop3Support = false;
      smtpSupport = false;
      withSidebar = false;
      smimeSupport = false;
      gpgmeSupport = false;
    };
  };
in import ./default.nix
(args // { overlays = [ overlay ] ++ (args.overlays or [ ]); })
