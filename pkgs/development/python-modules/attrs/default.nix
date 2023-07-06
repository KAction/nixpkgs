{ lib
, stdenv
, callPackage
, buildPythonPackage
, fetchFromGitHub
, python
, pythonOlder
, setuptools

# dependencies to build documentation, including "attrs" itself.
, sphinxHook
, attrs
, myst-parser
, furo
, sphinx-notfound-page
, sphinxcontrib-towncrier
}:

let
  inherit (python) pythonVersion;

in buildPythonPackage rec {
  pname = "attrs";
  version = "22.2.0";
  disabled = pythonOlder "3.6";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "python-attrs";
    repo = "attrs";
    rev = version;
    hash = "sha256-3IHV3tlarU0l90fcVxlZ19/JpLVjGP9irJ5+UIz5i4w=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  outputs = [
    "out"
    "testout"
  ];

  postInstall = ''
    # Install tests as the tests output.
    mkdir $testout
    cp -R conftest.py tests $testout
  '';

  pythonImportsCheck = [
    "attr"
  ];

  # pytest depends on attrs, so we can't do this out-of-the-box.
  # Instead, we do this as a passthru.tests test.
  doCheck = false;

  passthru = {
    tests.pytest = callPackage ./tests.nix { };

    doc = stdenv.mkDerivation {
      inherit src;
      name = "${pname}-${version}-doc";

      # Necessary hack so sphinx can import "sphinxcontrib.towncrier"
      patchPhase = ''
        sed -i '1i import sys; del sys.modules["sphinxcontrib"]' docs/conf.py
      '';

      dontConfigure = true;

      dontBuild = true;

      postInstallSphinx = ''
        mv $out/share/doc/* $out/share/doc/python${pythonVersion}-${pname}-${version}
      '';

      nativeBuildInputs = [
        sphinxHook
        attrs
        furo
        myst-parser
        sphinxcontrib-towncrier
        sphinx-notfound-page
      ];
    };
  };

  meta = with lib; {
    description = "Python attributes without boilerplate";
    homepage = "https://github.com/python-attrs/attrs";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
