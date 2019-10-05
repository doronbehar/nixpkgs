{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, libyaml
, fftwFloat
, ffmpeg
, chromaprint
, taglib
, libsamplerate
, pkgconfig
, wafHook
, pythonSupport ? false
, pythonPackages
, gaiaSupport ? true
# This one is not listed in upstream's instructions but it seems to be a
# requirement since the build fails with the error:
# [290/290] Linking build/src/libessentia.so
# /nix/store/cl1i6bfqnx48ipakj4px7pb1babzs23j-binutils-2.31.1/bin/ld: cannot find -lQtCore
# Probably because gaia which depends on qt4
, qt4
, gaia
, withVamp ? true
, withExamples ? true
}:

assert pythonSupport -> pythonPackages != null;
assert gaiaSupport -> gaia != null;
assert gaiaSupport -> qt4 != null;

stdenv.mkDerivation rec {
  pname = "essentia";
  # other versions fail to build
  version = "2.1_beta5";

  src = fetchFromGitHub {
    owner = "MTG";
    repo = "essentia";
    rev = "v${version}";
    sha256 = "0ig267wfxry2rjpij4fypf2zk7f59jd0n23l3807igbn2cmkgz4w";
  };
  patches = [
    (fetchpatch {
      # Make waf use ${PREFIX} to install examples - otherwise, our build fail
      # when trying to write to /usr/local/
      url = "https://github.com/MTG/essentia/pull/915.patch";
      sha256 = "00m8kpdpqazgnvdcbnp6lh3px71l542ggaz6f71aylxzp02sva8p";
    })
  ];

  nativeBuildInputs = [
    wafHook
    pkgconfig
  ];
  buildInputs = [
    libyaml
    fftwFloat
    taglib
    ffmpeg
    libsamplerate
    chromaprint
  ]
    ++ lib.optionals (pythonSupport) [
      (pythonPackages.python.withPackages(ps: with ps; [
        pyyaml
        numpy
      ]))
    ]
    ++ lib.optionals (gaiaSupport) [ gaia qt4 ]
  ;
  wafConfigureFlags = [
  ]
    ++ lib.optionals (pythonSupport) [ "--with-python" ]
    ++ lib.optionals (gaiaSupport) [ "--with-gaia" ]
    ++ lib.optionals (withVamp) [ "--with-vamp" ]
    ++ lib.optionals (withExamples) [ "--with-examples" ]
  ;

  meta = with lib; {
    homepage = "https://github.com/MTG/essentia";
    description = "Library for audio and music analysis, description and synthesis";
    maintainers = with maintainers; [ doronbehar ];
    platforms = platforms.all;
    license = licenses.agpl3;
  };
}
