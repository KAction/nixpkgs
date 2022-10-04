{ lib
, stdenv
, awscli
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonApplication rec {
  pname = "saws";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "donnemartin";
    repo = "saws";
    rev = version;
    hash = "sha256-yA6cKtebKbi8WIRtGzIkUQZixfnQrs8cbuFP0KhFP1U=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace 'click>=4.0,<7.0' 'click>=4.0'
  '';

  # Tests fail inside of prompt-toolkit with assertion self.stdin.istty()
  doCheck = false;

  propagatedBuildInputs = [
    awscli
    python3Packages.click
    python3Packages.configobj
    python3Packages.prompt-toolkit_1
  ];
}
