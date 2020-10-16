{ lib
, stdenv
, mkDerivation
, fetchFromGitHub
, osmosdr
}:

mkDerivation rec {
  pname = "gr-ais";
  version = "2015-12-20";
  src = fetchFromGitHub {
    owner = "bistromath";
    repo = "gr-ais";
    rev = "cdc1f52745853f9c739c718251830eb69704b26e";
    sha256 = "1vl3kk8xr2mh5lf31zdld7yzmwywqffffah8iblxdzblgsdwxfl6";
  };
  disabled = ["3.8"];

  buildInputs = [
    osmosdr
  ];

  meta = with lib; {
    description = "Gnuradio block for ais";
    homepage = "https://github.com/bistromath/gr-ais";
    license = licenses.gpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ mog ];
  };
}
