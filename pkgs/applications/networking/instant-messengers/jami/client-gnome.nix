{ stdenv
, src
, version
, jami-meta
# native
, cmake
, pkg-config
, wrapGAppsHook
# not native
, jami-daemon
, jami-lrc
, gtk3
, pcre
, qtbase
, xlibs
, clutter
, clutter-gtk
, libuuid
, webkitgtk
, libnotify
, libqrencode
, libcanberra-gtk3
, libnma
, libappindicator
, libindicator
}:

stdenv.mkDerivation rec {
  pname = "jami-client-gnome";

  inherit version src;
  sourceRoot = "ring-project/client-gnome";

  nativeBuildInputs = [
    pkg-config
    cmake
    wrapGAppsHook
  ];
  buildInputs = [
    jami-daemon
    jami-lrc
    gtk3
    qtbase
    pcre
    xlibs.libpthreadstubs
    xlibs.libXdmcp
    clutter
    clutter-gtk
    libuuid
    webkitgtk
    libnotify
    libqrencode
    libcanberra-gtk3
    libnma
    libappindicator
    libindicator
  ];

  # no tests available yet, see:
  # https://git.jami.net/savoirfairelinux/ring-client-gnome/blob/71690838b926e63c088e3fa0883f881365da1816/CMakeLists.txt#L334-336
  # doCheck = true;

  meta = jami-meta // {
    description = jami-meta.description + ": Gnome client";
  };
}
