{ lib, buildPythonPackage, fetchFromGitHub, sphinx }:

buildPythonPackage rec {
  pname = "sphinx-prompt";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "sbrunner";
    repo = "sphinx-prompt";
    rev = version;
    sha256 = "sha256-ClUPAIyPrROJw4GXeakA8U443Vlhy3P/2vFnAtyrPHU";
  };
  propagatedBuildInputs = [ sphinx ];

  meta = with lib; {
    description = "Sphinx plugin for typesetting shell prompt";
    homepage = "https://github.com/sbrunner/sphinx-prompt";
    licensee = licenses.mit;
  };
}
