{ stdenv
, src
, version
, jami-meta
# native
, autoreconfHook
, pkg-config
, perl # for pod2man
# for tests, currently disabled
, cppunit
# not native
, opendht
, gnutls
, pjsip
, secp256k1
, ffmpeg-full
, speex
, libyamlcpp
, jsoncpp
, zlib
, alsaLib
, libpulseaudio
, jack2
, portaudio
, libupnp
, libnatpmp
, openssl
, systemd
, libarchive
, msgpack
, asio
, restinio
, fmt
, http-parser
, srtp
, dbus
, dbus_cplusplus
}:

stdenv.mkDerivation rec {
  pname = "jami-daemon";

  inherit version src;
  sourceRoot = "ring-project/daemon";

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    perl # for pod2man
  ];
  buildInputs = [
    opendht
    gnutls
    secp256k1
    pjsip
    ffmpeg-full
    speex
    libyamlcpp
    jsoncpp
    zlib
    alsaLib
    libpulseaudio
    jack2
    portaudio
    libupnp
    libnatpmp
    openssl
    systemd # libudev
    libarchive
    msgpack
    asio
    restinio
    fmt
    http-parser
    dbus
    dbus_cplusplus
  ];
  checkInputs = [
    cppunit
  ];
  # Tests fail, see https://review.jami.net/c/ring-daemon/+/15021
  doCheck = false;

  # To build faster
  enableParallelBuilding = true;

  passthru = {
    inherit pjsip opendht
    # ffmpeg-full
    ;
  };

  meta = jami-meta // {
    description = jami-meta.description + ": Daemon";
  };
}
