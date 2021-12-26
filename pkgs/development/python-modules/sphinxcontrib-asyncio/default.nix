{ lib, buildPythonPackage, fetchFromGitHub, sphinx }:

buildPythonPackage rec {
  pname = "sphinxcontrib-asyncio";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = pname;
    rev = "v${version}";
    sha256 = "1ylz24zzycxfy3vp4gy782qxvha86jafrlvyyczq8lavl83j6670";
  };

  propagatedBuildInputs = [ sphinx ];

  doCheck = false; # no tests

  pythonImportsCheck = [ "sphinxcontrib.asyncio" ];

  meta = with lib; {
    description = "Sphinx async-specific markup extension";
    homepage = "https://github.com/aio-libs/sphinxcontrib-asyncio";
    maintainers = with maintainers; [ kaction ];
    license = licenses.asl20;
  };
}
