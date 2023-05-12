{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, setuptools
, pytestCheckHook
, sphinxHook
, sphinx_rtd_theme
}:

buildPythonPackage rec {
  pname = "aiosql";
  version = "8.0";
  outputs = [ "out" "doc" ];
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "nackjicholson";
    repo = "aiosql";
    rev = "refs/tags/${version}";
    hash = "sha256-cE89w1CbDqlkryRr3yAdSxAtWzV1+O+n41ihTwYWelE=";
  };

  sphinxRoot = "docs/source";

  nativeBuildInputs = [
    pytestCheckHook
    sphinxHook
    poetry-core
    sphinx_rtd_theme
  ];

  pythonImportsCheck = [ "aiosql" ];

  meta = with lib; {
    description = "Simple SQL in Python";
    homepage = "https://nackjicholson.github.io/aiosql/";
    license = with licenses; [ bsd2 ];
    maintainers = with maintainers; [ kaction ];
  };
}
