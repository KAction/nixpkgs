{ lib, buildPythonPackage, fetchFromGitHub, sphinx, towncrier, pytest }:

buildPythonPackage rec {
  pname = "sphinxcontrib-towncrier";
  version = "0.2.0a0";

  src = fetchFromGitHub {
    owner = "sphinx-contrib";
    repo = pname;
    rev = "v${version}";
    sha256 = "1qhbzkbaryr4zvbri6czbp5z5gx2jvxi18gjihna6qr56pfwgy5v";
  };

  # Upstream build system does not do it. I have no idea how it happens to
  # work in the wild, but it definitely does not work in Nix otherwise.
  postPatch = ''
    cat <<EOF > src/sphinxcontrib/__init__.py
    __import__('pkg_resources').declare_namespace(__name__)
    EOF
  '';

  propagatedBuildInputs = [ sphinx towncrier ];

  checkInputs = [ pytest ];

  pythonImportsCheck = [ "sphinxcontrib.towncrier" ];

  meta = with lib; {
    description = "RST directive for injecting towncrier-generated changelog";
    homepage = "https://github.com/sphinx-contrib/sphinxcontrib-towncrier";
    maintainers = with maintainers; [ kaction ];
    license = licenses.bsd3;
  };
}
