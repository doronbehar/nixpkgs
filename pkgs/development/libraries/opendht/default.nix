{ stdenv, fetchFromGitHub, cppunit, http-parser, fmt, fetchpatch
, cmake, pkg-config, libtasn1, p11-kit, restinio, jsoncpp, openssl, systemd
, asio, nettle, gnutls, msgpack, readline, libargon2, breakpointHook
}:

stdenv.mkDerivation rec {
  pname = "opendht";
  # The latest release fails to build and run tests, see:
  # https://github.com/savoirfairelinux/opendht/issues/509
  version = "unstable-2020-08-20";

  src = fetchFromGitHub {
    owner = "savoirfairelinux";
    repo = "opendht";
    rev = "4d70c214b0b69deb0ca4bffbf3056131b013378d";
    sha256 = "17zgj3s3nngvvqr6vh4pbwj44v53dxsp60nskfay9ln525r2fj96";
  };

  nativeBuildInputs =
    [ cmake
      pkg-config
    ];

  buildInputs =
    [ asio
      nettle
      gnutls
      http-parser
      fmt
      msgpack
      readline
      libargon2
      libtasn1
      p11-kit
      restinio
      jsoncpp
      systemd
      openssl
    ];

  checkInputs = [
    cppunit
  ];

  # The tests fail, but we don't complain because it's an unstable release
  # anyway. If savoirfairelinux will ever start using real releases with tests
  # that are supposed to succeed, coordinated with a real jami release with
  # tests passing for it too, most of the logic should be implemented here
  # already.
  doCheck = false;
  cmakeFlags = [
    "-DOPENDHT_SYSTEMD=ON"
    "-DOPENDHT_SYSTEMD_UNIT_FILE_LOCATION=${placeholder "out"}/lib/systemd/system"
    "-DOPENDHT_LTO=ON"
    "-DOPENDHT_PROXY_SERVER=ON"
    "-DOPENDHT_PUSH_NOTIFICATIONS=ON"
    "-DOPENDHT_PROXY_SERVER_IDENTITY=ON"
    "-DOPENDHT_PROXY_CLIENT=ON"
    "-DOPENDHT_PROXY_OPENSSL=ON"
    "-DOPENDHT_PEER_DISCOVERY=ON"
    "-DOPENDHT_INDEX=ON"
    "-DOPENDHT_C=ON"
  ] ++ stdenv.lib.optionals doCheck [
    "-DOPENDHT_TESTS=ON"
    "-DOPENDHT_DISABLE_NETWORK_TESTS=ON"
  ];

  # shared library needs to be accessible to test runners
  preCheck = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}$(pwd)
  '';

  outputs = [ "out" "lib" "dev" "man" ];

  meta = with stdenv.lib; {
    description = "A C++11 Kademlia distributed hash table implementation";
    homepage    = "https://github.com/savoirfairelinux/opendht";
    license     = licenses.gpl3Plus;
    maintainers = with maintainers; [ taeer olynch thoughtpolice ];
    platforms   = platforms.linux;
  };
}
