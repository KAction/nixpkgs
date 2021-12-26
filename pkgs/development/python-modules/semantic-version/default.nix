{ lib, fetchPypi, buildPythonPackage }:

let f = { version, sha256 }:
  buildPythonPackage rec {
    pname = "semantic_version";
    inherit version;

    src = fetchPypi {
      inherit pname version sha256;
    };

    # ModuleNotFoundError: No module named 'tests'
    doCheck = false;

    meta = with lib; {
      description = "A library implementing the 'SemVer' scheme";
      license = licenses.bsdOriginal;
      maintainers = with maintainers; [ layus makefu ];
    };
  };
in {
  latest = f {
    version = "2.8.5";
    sha256 = "0m4avx8zdkzc7qglv5zlr54g8yna5vl098drg5396ql7aph2vjyj";
  };

  # We need version < 2.7 as dependency of sphinx-releases. Sigh.
  release_2_6 = f {
    version = "2.6.0";
    sha256 = "1h2l9xyg1zzsda6kjcmfcgycbvrafwci283vcr1v5sbk01l2hhra";
  };
}
