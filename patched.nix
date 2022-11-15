args:
let
  overlay = self: super: {

    # Avoid dependency on statically-built python which can't load C modules,
    # so even standard library is not fully functional.
    fish =
      let
        stage1 = super.fish.override {
          usePython = false;
        };
      in stage1.overrideAttrs (old: {
        doCheck = false;
        checkInputs = [];
      });
    mpop = super.mpop.override {
      nlsSupport = false;
      idnSupport = false;
      gsaslSupport = false;
      sslLibrary = "openssl";
    };
    msmtp = super.msmtp.override {
      withKeyring = false;
      withSystemd = false;
    };
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
    w3m = super.w3m.override {
      x11Support = false;
      mouseSupport = false;
      graphicsSupport = false;

      # It is common to redirect http to https even for websites that have
      # nothing to do with authentication, so have no choice.
      sslSupport = true;
    };
    nix = super.nix.override { withAWS = false; };
  };
in import ./default.nix
(args // { overlays = [ overlay ] ++ (args.overlays or [ ]); })
