{ lib, buildPythonPackage, fetchFromGitHub, sphinx, sphinx-releases, sphinxHook
}:

buildPythonPackage rec {
  pname = "sphinx-aiohttp-theme";
  version = "0.1.6";
  outputs = [ "out" "doc" ];

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiohttp-theme";
    rev = "v${version}";
    sha256 = "0waqva4w36nib6w1lwy24v3g6xj2zb300q6j1ghs7zil4sib7a70";
  };

  propagatedBuildInputs = [ sphinx ];

  nativeBuildInputs = [ sphinxHook sphinx-releases ];

  doCheck = false; # no tests

  pythonImportsCheck = [ "aiohttp_theme" ];

  meta = with lib; {
    description = "Sphinx theme used by aiohttp project";
    homepage = "https://github.com/aio-libs/aiohttp-theme";
    maintainers = with maintainers; [ kaction ];
    license = licenses.bsd3;
  };
}
