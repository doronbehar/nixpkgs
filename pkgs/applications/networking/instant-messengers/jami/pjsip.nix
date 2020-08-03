{ stdenv
, jami-src # To get the patches
, gnutls
, pkg-config
, breakpointHook
, pjsip
}:

let
  # Jami requires a patched version of pjsip. Within the jami's source tarball,
  # the directory `daemon/contrib/src/pjproject` contains patches from which we
  # apply the patches listed here:
  # https://git.jami.net/savoirfairelinux/ring-daemon/blob/master/contrib/src/pjproject/rules.mak#L5
  # NOTE: Not all of the patches found in that directory are needed or even
  # apply.
  #
  # TODO: Make update script update this list according to the package.json of
  # jami's tarball, or make the update script copy the patches to nixpkgs
  # inorder to spare the evaluation requiring downloading the jami source
  # tarball.
  patches-names = [
    "0001-rfc6544.patch"
    "0002-rfc2466.patch"
    "0003-add-tcp-keep-alive.patch"
    "0004-multiple_listeners.patch"
    "0005-fix_ebusy_turn.patch"
    "0006-ignore_ipv6_on_transport_check.patch"
    "0007-pj_ice_sess.patch"
    "0008-fix_ioqueue_ipv6_sendto.patch"
    "0009-add-config-site.patch"
    "0010-fix-pkgconfig.patch"
    "0011-fix-tcp-death-detection.patch"
    "0012-fix-turn-shutdown-crash.patch"
    # This patch seems to be used by upstream's build but it won't apply:
    #"0013-Assign-unique-local-preferences-for-candidates-with-.patch"
    "0014-Add-new-compile-time-setting-PJ_ICE_ST_USE_TURN_PERM.patch"
    "0015-update-local-preference-for-peer-reflexive-candidate.patch"
  ];
in
  pjsip.overrideAttrs(old: {
    postPatch  = ''
      mkdir jami-patches
      tar -C jami-patches --strip-components=5 -xf ${jami-src} ring-project/daemon/contrib/src/pjproject
      for patch_name in ${builtins.concatStringsSep " " patches-names}; do
        echo using patch $patch_name
        patch --force -p1 -i jami-patches/$patch_name
      done
    '';
    configureFlags = [
      # See https://git.jami.net/savoirfairelinux/ring-daemon/blob/master/contrib/src/pjproject/rules.mak#L5
      # TODO As part of the update script, make this list update itself as well.
      "--disable-sound"
      "--enable-video"
      "--enable-ext-sound"
      "--enable-epoll"
      "--disable-speex-aec"
      "--disable-g711-codec"
      "--disable-l16-codec"
      "--disable-gsm-codec"
      "--disable-g722-codec"
      "--disable-g7221-codec"
      "--disable-speex-codec"
      "--disable-ilbc-codec"
      "--disable-opencore-amr"
      "--disable-silk"
      "--disable-sdl"
      "--disable-ffmpeg"
      "--disable-v4l2"
      "--disable-openh264"
      "--disable-resample"
      "--disable-libwebrtc"
    ];
    buildInputs = old.buildInputs ++ [
      gnutls
    ];
    nativeBuildInputs = [
      pkg-config
    ];
    # Without these linking jami-daemon fails with various errors, such as:
    #
    #    /nix/store/k6rnzlmcvm37d0nw4fkz6ivmykmrdn39-binutils-2.31.1/bin/ld: /nix/store/s5ic48dwss6izfm0s2gpyic8c27493ik-pjsip-2.10/lib/libpj-x86_64-unknown-linux-gnu.a(timer.o): relocation R_X86_64_32 against `.rodata.str1.8' can not be used when making a shared object; recompile with -fPI
    #
    # and when running dring from `${jami-daemon}/lib/dring/dring`:
    #
    #    ==27318==ASan runtime does not come first in initial library list; you should either link runtime to your application or manually preload it with LD_PRELOAD.
    #
    # Source: https://git.savannah.gnu.org/cgit/guix.git/tree/gnu/packages/jami.scm?id=1c15d30521fc6e8a03a7a244f66db5ea9a893012#n141
    # CFLAGS="-fPIC -DNDEBUG";
    # CXXFLAGS="-fPIC -DNDEBUG";
  })
