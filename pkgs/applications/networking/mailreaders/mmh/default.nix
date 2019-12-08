{ stdenv,
  fetchgit,
  ncurses,
  autoreconfHook,
  flex
}:
stdenv.mkDerivation rec {
  pname = "mmh-unstable";
  version = "2019-09-08";

  src = fetchgit {
    url = "http://git.marmaro.de/mmh";
    rev = "431604647f89d5aac7b199a7883e98e56e4ccf9e";
    sha256 = "03331q8lsmwrlkhlrywnaz8cycja32h6bn0akjl8gfddhhyb06rh";
  };

  buildInputs = [ ncurses ];
  nativeBuildInputs = [ autoreconfHook flex ];

  meta = with stdenv.lib; {
    description = "Set of electronic mail handling programs";
    homepage = "http://marmaro.de/prog/mmh";
    license = licenses.bsd3;
    platforms = platforms.unix;
    broken = stdenv.isDarwin;
    maintainers = with maintainers; [ kaction ];
  };
}
