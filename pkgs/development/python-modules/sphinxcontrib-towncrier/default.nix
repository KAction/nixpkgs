{ lib
, fetchFromGitHub
, buildPythonPackage
, setuptools
, setuptools-scm
, setuptools-scm-git-archive

, importlib-metadata
, sphinx
, towncrier
, tomli

, sphinxHook
, myst-parser
, furo
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-towncrier";
  version = "0.3.2a0";
  format = "pyproject";
  outputs = [ "out" "doc" ];

  src = fetchFromGitHub {
    owner = "sphinx-contrib";
    repo = "sphinxcontrib-towncrier";
    rev = "v${version}";
    hash = "sha256-HDdAMz1iFj8LN91Cw3xge+RJldHF02p3xLWAOzJh5qE=";
  };

  nativeBuildInputs = [
    sphinxHook
    myst-parser
    furo

    setuptools
    setuptools-scm
    setuptools-scm-git-archive
  ];

  propagatedBuildInputs = [
    importlib-metadata
    sphinx
    towncrier
    tomli
  ];

  pythonImportsCheck = [ "sphinxcontrib.towncrier" ];

  meta = with lib; {
    description = "An RST directive for injecting a Towncrier-generated changelog draft";
    homepage = "https://pypi.org/project/sphinxcontrib-towncrier/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ kaction ];
  };
}
