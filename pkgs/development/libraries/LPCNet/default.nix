{ stdenv
, fetchFromGitHub
, fetchurl # to download test data
, fetchpatch
, cmake
, codec2
# for tests
, octave
}:

stdenv.mkDerivation rec {
  pname = "LPCNet";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "drowe67";
    repo = "LPCNet";
    rev = "v${version}";
    sha256 = "1p9agrig9sfwdfx59gmc0mvcqimxq3537zs5061if5m5ssjysj1r";
  };
  NN_model = fetchurl {
    url = "http://rowetel.com/downloads/deep/lpcnet_191005_v1.0.tgz";
    sha256 = "1j1695hm2pg6ri611f9kr3spm4yxvpikws55z9zxizai8y94152h";
  };
  # Enable to specify NN_model url via cmake flag
  patches = [
    (fetchpatch {
      name = "cmake-url.patch";
      url = "https://github.com/drowe67/LPCNet/pull/16.patch";
      sha256 = "0q964iilpaafz7hfs474wnhxazgjxa5v1s2v6s2mj4qga04lh3qg";
    })
  ];
  prePatch = ''
    patchShebangs *.sh unittest/*.sh
  '';
  cmakeFlags = [
    "-DLPCNET_URL=${NN_model}"
  ];

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    codec2
  ];
  checkInputs = [
    octave
  ];

  # Fail, see https://github.com/drowe67/LPCNet/issues/17
  doCheck = false;
  preCheck = ''
    # test scripts expect build_linux to be the build directory
    ln -sr ../build ../build_linux
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}/build/source/build/src"
    echo current LD_LIBRARY_PATH is $LD_LIBRARY_PATH
  '';

  meta = with stdenv.lib; {
    description = "GUI Application for FreeDV – open source digital voice for HF radio";
    homepage = "https://freedv.org/";
    license = licenses.bsd3;
    maintainers = [ maintainers.doronbehar ];
    # Should support all platforms but I can't test other
    platforms = platforms.linux;
  };
}

