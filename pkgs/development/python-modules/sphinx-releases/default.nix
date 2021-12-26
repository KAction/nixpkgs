{ lib
, buildPythonPackage
, fetchFromGitHub
# runtime dependencies
, semantic-version_2_6
, sphinx
# tests
, pytest
# documentation
, sphinx_rtd_theme
, sphinxHook
}:

buildPythonPackage rec {
  pname = "sphinx-releases";
  version = "1.6.3";
  outputs = [ "out" "doc" ];

  src = fetchFromGitHub {
    owner = "bitprophet";
    repo = "releases";
    rev = "${version}";
    sha256 = "0v8g43ikl3c64lwi0giyap9l9rl9gp9b0x2qvykwnd61p3lrwzax";
  };

  propagatedBuildInputs = [ sphinx semantic-version_2_6 ];

  checkInputs = [ pytest ];

  nativeBuildInputs = [ sphinxHook sphinx_rtd_theme ];

  pythonImportsCheck = [ "releases" ];

  meta = with lib; {
    description = "Sphinx extension to keep changelong in merge-friendly way";
    homepage = "https://github.com/bitprophet/releases";
    maintainers = with maintainers; [ kaction ];
    license = licenses.asl20;
  };
}
