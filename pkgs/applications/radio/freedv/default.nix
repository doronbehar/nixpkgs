{ stdenv
, fetchFromGitHub
, cmake
, pkg-config
, codec2
, LPCNet
, portaudio
, libsamplerate
, libsndfile
, alsaLib
, hamlib
, wxGTK31
, speexdsp
, libao
}:

stdenv.mkDerivation rec {
  pname = "freedv";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "drowe67";
    repo = "freedv-gui";
    rev = "v${version}";
    sha256 = "1gxrgw24bacc0ahbsadsd7zb4n38s12nz017kp1rbm4yp907raff";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    codec2
    LPCNet
    portaudio
    libsamplerate
    libsndfile
    alsaLib
    hamlib
    wxGTK31
    speexdsp
    libao
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "GUI Application for FreeDV – open source digital voice for HF radio";
    homepage = "https://freedv.org/";
    license = licenses.lgpl21;
    maintainers = [ maintainers.doronbehar ];
    platforms = platforms.all;
  };
}
