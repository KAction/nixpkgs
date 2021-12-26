{ lib
, stdenv
, buildPythonPackage
, fetchPypi
, fetchFromGitHub
, pythonOlder
, sphinxHook
# install_requires
, attrs
, charset-normalizer
, multidict
, async-timeout
, yarl
, frozenlist
, aiosignal
, aiodns
, brotli
, cchardet
, asynctest
, typing-extensions
, idna-ssl
# tests_require
, async_generator
, freezegun
, gunicorn
, pytest-mock
, pytestCheckHook
, re-assert
, trustme
# building C stuff from the source
, cython
# building documentation
, sphinxcontrib-asyncio
, sphinxcontrib-blockdiag
, sphinxcontrib-towncrier
, sphinx-aiohttp-theme
, pytest-aiohttp
, pytest
}:
let
  pname = "aiohttp";
  version = "3.8.1";

  # Building documentation requires files not present in PyPi archive, but
  # building package itself from git snapshot it painful due complicated build
  # system of C extensions.
  #
  # TODO: Somebody strong and brave should build package from git.

  doc = stdenv.mkDerivation {
    inherit pname;
    version = "${version}-doc";  # fake path from multiple-output derivation
    phases = [ "unpackPhase" "buildSphinxPhase" "installSphinxPhase" ];

    src = fetchFromGitHub {
      owner = "aio-libs";
      repo = pname;
      rev = "v${version}";
      sha256 = "1f6idvb641qn4217s2dg11vdwnqn1sydl1j2mpn3n21zjbifhdp8";
    };

    nativeBuildInputs = [
      aiohttp
      sphinxHook
      pytest
      pytest-aiohttp
      sphinx-aiohttp-theme
      sphinxcontrib-asyncio
      sphinxcontrib-blockdiag
      sphinxcontrib-towncrier
    ];
  };

  aiohttp = buildPythonPackage rec {
    inherit pname version;
    disabled = pythonOlder "3.6";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0y3m1dzl4h6frg8vys0fc3m83ijd1plfpihv3kvmxqadlphp2m7w";
    };

    postPatch = ''
      sed -i '/--cov/d' setup.cfg
    '';

    buildInputs = [ cython ];

    preBuild = ''
      # make .develop
    '';

    propagatedBuildInputs = [
      attrs
      charset-normalizer
      multidict
      async-timeout
      yarl
      typing-extensions
      frozenlist
      aiosignal
      aiodns
      brotli
      cchardet
    ] ++ lib.optionals (pythonOlder "3.8") [
      asynctest
      typing-extensions
    ] ++ lib.optionals (pythonOlder "3.7") [
      idna-ssl
    ];

    checkInputs = [
      async_generator
      freezegun
      gunicorn
      pytest-mock
      pytestCheckHook
      re-assert
      trustme
    ];

    disabledTests = [
      # Disable tests that require network access
      "test_client_session_timeout_zero"
      "test_mark_formdata_as_processed"
      "test_requote_redirect_url_default"
    ] ++ lib.optionals stdenv.is32bit [
      "test_cookiejar"
    ] ++ lib.optionals stdenv.isDarwin [
      "test_addresses"  # https://github.com/aio-libs/aiohttp/issues/3572, remove >= v4.0.0
      "test_close"
    ];

    disabledTestPaths = [
      "test_proxy_functional.py" # FIXME package proxy.py
    ];

    __darwinAllowLocalNetworking = true;

    # aiohttp in current folder shadows installed version
    # Probably because we run `python -m pytest` instead of `pytest` in the hook.
    preCheck = ''
      cd tests
    '';

    meta = with lib; {
      description = "Asynchronous HTTP Client/Server for Python and asyncio";
      license = licenses.asl20;
      homepage = "https://github.com/aio-libs/aiohttp";
      maintainers = with maintainers; [ dotlambda ];
    };
  };
in aiohttp // { inherit doc; }
