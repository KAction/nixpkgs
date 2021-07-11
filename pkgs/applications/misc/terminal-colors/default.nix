{ stdenv, lib, help2man, python3, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "terminal-colors";
  version = "3.0.1";
  outputs = [ "out" "man" ];

  src = fetchFromGitHub {
    owner = "eikenb";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-hekt77/FhSTMEARVuck49/Q1dIuqkwbOYmgGD1IItyc=";
  };

  buildInputs = [ python3 ];
  nativeBuildInputs = [ help2man ];

  postPatch =
    # This sed command modifies output of --version command in way that
    # makes manpage generated by help2man(1) prettier.
    ''
      sed -r -i "3s/([0-9.]+)/$pname - \1\\n/" ./$pname
    ''
    # Upstream shebang of "terminal-colors" python script uses
    # /usr/bin/env, which is not present in Nix sandbox, so we need to
    # patch it before running help2man, otherwise it would fail with "no
    # such file or directory".
    + ''
      patchShebangs .
    '';

  buildPhase = ''
    runHook preBuild

    help2man -n 'display terminal colors' -N ./$pname > $pname.1

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D -m755 ./$pname -t $out/bin
    install -D -m644 ./$pname.1 -t $man/share/man/man1

    runHook postInstall
  '';

  meta = with lib; {
    description = "Script displaying terminal colors in various formats";
    homepage = "https://github.com/eikenb/terminal-colors";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ kaction ];
  };
}
