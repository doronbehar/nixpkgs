{ stdenv
, src
, version
, jami-meta
# native
, cmake
, pkg-config
# for tests, currently disabled
, cppunit
# not native
, jami-daemon
, qtbase
, qttools
}:

stdenv.mkDerivation rec {
  pname = "jami-lrc";

  inherit version src;
  sourceRoot = "ring-project/lrc";

  nativeBuildInputs = [
    pkg-config
    cmake
    qttools
  ];
  buildInputs = [
    jami-daemon
    qtbase
  ];
  # tests are disabled, see: https://git.jami.net/savoirfairelinux/ring-lrc/issues/357
  doCheck = false;
  # checkInputs = [
    # cppunit
  # ];
  cmakeFlags = [
    # "-DENABLE_TEST=true"
    "-DRING_BUILD_DIR=${jami-daemon}/include"
    "-DRING_XML_INTERFACES_DIR=${jami-daemon}/share/dbus-1/interfaces"
  ];

  meta = jami-meta // {
    description = jami-meta.description + ": client library";
  };
}
