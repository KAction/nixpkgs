{ buildPythonPackage
, fetchFromGitHub
, lib
, fetchpatch
, semantic-version
, sphinx
}:

buildPythonPackage rec {
  pname = "releases";
  version = "1.6.3";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "bitprophet";
    repo = pname;
    rev = version;
    hash = "sha256-XX2e6bjBNMun31h0sNJ9ieZE01U+PhA5JYYNOuMgD20=";
  };

  patches = [
    (fetchpatch { # PR 86 (Fix compatibility with >=python-semanticversion-2.7.0)
      url = "https://github.com/bitprophet/releases/commit/8787236dffb7383427b3e1448ece9a5b3eaf5257.patch";
      sha256 = "sha256-VdNxkne8mm11fHgTFDQyCxHX85f8DVaY67ZJxXLYYAQ=";
    })
  ];

  postPatch = ''
    substituteInPlace setup.py --replace "semantic_version<2.7" "semantic_version"
  '';

  propagatedBuildInputs = [ semantic-version sphinx ];

  # Test suite doesn't run. See https://github.com/bitprophet/releases/issues/95.
  doCheck = false;

  pythonImportsCheck = [ "releases" ];

  meta = with lib; {
    description = "A Sphinx extension for changelog manipulation";
    homepage = "https://github.com/bitprophet/releases";
    license = licenses.bsd2;
    maintainers = with maintainers; [ samuela ];
  };
}
