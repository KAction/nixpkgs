{ lib, buildPythonApplication, fetchFromGitHub
# python packages
, tabulate
, xdg
, graphql-core
, requests
, readlike
, pyyaml
}:

buildPythonApplication rec {
  pname = "gqt";
  version = "0.108.0";

  src = fetchFromGitHub {
    owner = "eerimoq";
    repo = "gqt";
    rev = version;
    hash = "sha256-KngnfPCLQQ08UE12egSoU0K+tFgtqyhlxauwP9tGPyE=";
  };

  propagatedBuildInputs = [ tabulate xdg graphql-core requests readlike pyyaml ];
}
