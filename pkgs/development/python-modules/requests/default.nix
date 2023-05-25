{ lib
, stdenv
, brotlicffi
, buildPythonPackage
, certifi
, chardet
, charset-normalizer
, fetchFromGitHub
, idna
, pysocks
, pytest-mock
, pytest-xdist
, pytestCheckHook
, pythonOlder
, python
, urllib3
, sphinxHook
}:

buildPythonPackage rec {
  pname = "requests";
  version = "2.29.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  __darwinAllowLocalNetworking = true;

  src = fetchFromGitHub {
    owner = "psf";
    repo = "requests";
    rev = "v${version}";
    sha256 = "sha256-Zj75qTE21P1h6M20jFZc3vjCMZl7HFXLDBGKPLtLpa8=";
  };

  propagatedBuildInputs = [
    brotlicffi
    certifi
    charset-normalizer
    idna
    urllib3
  ];

  passthru = {
    optional-dependencies = {
      security = [];
      socks = [
        pysocks
      ];
      use_chardet_on_py3 = [
        chardet
      ];
    };

    doc = stdenv.mkDerivation {
      # Forge look and feel of multi-output derivation as best as we can.
      #
      # Using 'outputs = [ "doc" ];' breaks a lot of assumptions.
      name = "${pname}-${version}-doc";
      inherit src pname version;

      nativeBuildInputs = [ sphinxHook ];

      dontConfigure = true;
      dontBuild = true;
      dontInstall = true;

      postInstallSphinx = ''
        mv $out/share/doc/* $out/share/doc/python$pythonVersion-$pname-$version
      '';

      inherit (python) pythonVersion;
      inherit meta;
    };
  };

  nativeCheckInputs = [
    pytest-mock
    pytest-xdist
    pytestCheckHook
  ]
  ++ passthru.optional-dependencies.socks;

  disabledTests = [
    # Disable tests that require network access and use httpbin
    "requests.api.request"
    "requests.models.PreparedRequest"
    "requests.sessions.Session"
    "requests"
    "test_redirecting_to_bad_url"
    "test_requests_are_updated_each_time"
    "test_should_bypass_proxies_pass_only_hostname"
    "test_urllib3_pool_connection_closed"
    "test_urllib3_retries"
    "test_use_proxy_from_environment"
    "TestRequests"
    "TestTimeout"
  ] ++ lib.optionals (stdenv.isDarwin && stdenv.isAarch64) [
    # Fatal Python error: Aborted
    "test_basic_response"
    "test_text_response"
  ];

  disabledTestPaths = lib.optionals (stdenv.isDarwin && stdenv.isAarch64) [
    # Fatal Python error: Aborted
    "tests/test_lowlevel.py"
  ];

  pythonImportsCheck = [
    "requests"
  ];

  meta = with lib; {
    description = "HTTP library for Python";
    homepage = "http://docs.python-requests.org/";
    changelog = "https://github.com/psf/requests/blob/v${version}/HISTORY.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ fab ];
  };
}
