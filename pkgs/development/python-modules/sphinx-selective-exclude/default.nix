{ lib
, buildPythonPackage
, fetchFromGitHub
, sphinx
, pythonImportsCheckHook
}:

buildPythonPackage rec {
  pname = "sphinx-selective-exclude";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "pfalcon";
    repo = "sphinx_selective_exclude";
    rev = "v${version}";
    hash = "sha256-KQ/3kDMAgGY89HBdGdFYUaq567p/S80dY1iDGfD6610=";
  };

  nativeBuildInputs = [ pythonImportsCheckHook ];

  propagatedBuildInputs = [ sphinx ];

  pythonImportsCheck = [ "sphinx_selective_exclude" ];

  meta = with lib; {
    description = "A sphinx extension to make only:: directive work in an intuitive manner";
    homepage = "https://github.com/executablebooks/sphinx-design";
    license = licenses.mit;
    maintainers = with maintainers; [ marsam ];
  };
}
