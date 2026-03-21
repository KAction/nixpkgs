let
  pkgs = import ./. { };
in
pkgs.rc.override {
  editlineSupport = true;
  readlineSupport = false;
  lineEditingLibrary = "editline";
}
