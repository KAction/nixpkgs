{ lib, stdenv, callPackage, buildPythonPackage, fetchFromGitHub, furo, sphinx }:

# Sphinx depends on attrs, so attempt to just add it into dependencies causes
# loop. I tried to break the loop with build stages and overrides, but it
# is too complicated (for me, ~kaction), so I build documentation in separate
# derivation and attach result into the main derivation. Name of documentation
# derivation is fudged to look indistinguishable from genuine "doc" output.
let
  version = "21.2.0";
  src = fetchFromGitHub {
    owner = "python-attrs";
    repo = "attrs";
    rev = version;
    sha256 = "1bn7745ddxm4wsdzqxp1d7dvgqnzvnxjazz1g02di4nmxncxp051";
  };

  main = buildPythonPackage rec {
    inherit src version;

    pname = "attrs";
    outputs = [ "out" "testout" ];

    postInstall = ''
      # Install tests as the tests output.
      mkdir $testout
      cp -R tests $testout/tests
    '';

    pythonImportsCheck = [ "attr" ];

    # pytest depends on attrs, so we can't do this out-of-the-box.
    # Instead, we do this as a passthru.tests test.
    doCheck = false;

    passthru.tests = { pytest = callPackage ./tests.nix { }; };

    meta = with lib; {
      description = "Python attributes without boilerplate";
      homepage = "https://github.com/hynek/attrs";
      license = licenses.mit;
    };
  };

  doc = stdenv.mkDerivation {
    inherit src;
    name = main.name + "-doc";
    nativeBuildInputs = [ sphinx furo ];

    buildPhase = ''
      make -C docs html
    '';
  };

in main // { inherit doc; }
