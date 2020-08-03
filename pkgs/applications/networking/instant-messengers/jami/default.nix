{ callPackage
, stdenv
, fetchurl
, libsForQt5 # To callPackage clients drvs with qtbase in scope
}:

rec {
  # TODO: Update this via a maintainers update script
  version = "20200825.3.1ae25f3";
  src = fetchurl {
    url = "https://dl.jami.net/ring-release/tarballs/jami_${version}.tar.gz";
    sha256 = "03j91wramhpj5nyf9iv048jzk4ff3jr67r33y20kvpymy10bbq7c";
  };
  jami-meta = with stdenv.lib; {
    description = "SIP-compatible distributed peer-to-peer softphone and SIP-based instant messenger";
    homepage = "https://jami.net/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.doronbehar ];
    platforms = platforms.linux;
  };

  pjsip = callPackage ./pjsip.nix {
    # Patches for pjsip are included in jami's src
    jami-src = src;
  };

  # ffmpeg = ffmpeg-full.overrideAttrs(old: {
    # configureFlags = old.configureFlags ++ [
      # "--extra-cxxflags=-fPIC"
      # "--extra-cflags=-fPIC"
    # ];
  # });

  jami-daemon = callPackage ./daemon.nix {
    inherit version src jami-meta pjsip;
  };
  jami-lrc = libsForQt5.callPackage ./lrc.nix {
    inherit version src jami-meta jami-daemon;
  };
  # It's a gnome client, but it needs qtbase from some reason, so we use
  # libsForQt5
  jami-client-gnome = libsForQt5.callPackage ./client-gnome.nix {
    inherit version src jami-meta jami-daemon jami-lrc;
  };
}
