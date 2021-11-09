{ lib, buildPythonPackage, fetchFromGitHub, sphinx, docutils, pytest
, beautifulsoup4 }:

buildPythonPackage rec {
  pname = "sphinx-tabs-unstable";
  # stable release 3.2.0 depends on docutils=0.16; we already switched
  # to 0.17 in nixpkgs. Upstream commit that switched to 0.17 also
  # updated lots of tests, so patching just setup.py wouldn't be enough.
  version = "2021-10-02";
  outputs = [ "out" "doc" ];

  src = fetchFromGitHub {
    owner = "executablebooks";
    repo = "sphinx-tabs";
    rev = "e15bc851c6fec6d871d028b369facc4834f675e2";
    sha256 = "sha256-HIDk5qynr5SwxHPPzxwu0nRUv489xmk3mmkvrqWi+vY=";
  };
  propagatedBuildInputs = [ sphinx docutils ];
  nativeBuildInputs = [ sphinx ];
  checkInputs = [ pytest beautifulsoup4 ];

  postBuild = ''
    PYTHONPATH=$PWD:$PYTHONPATH sphinx-build -b html ./docs ./html
  '';
  postInstall = ''
    mkdir -p     $out/share/doc/python/sphinx-tabs
    cp -r ./html $out/share/doc/python/sphinx-tabs
  '';

  pythonImportsCheck = [ "sphinx_tabs" ];

  meta = with lib; {
    description = "library to create tabbed content in Sphinx documentation";
    homepage = "https://sphinx-tabs.readthedocs.io/en/latest/";
    license = licenses.mit;
  };
}
