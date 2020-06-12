{ stdenv
, lib
, fetchurl
# native
, pkg-config
, cppunit
, intltool
, libxslt
, breakpointHook
, python2
, perl
# basic
, curl
, openobex
, bluez
, pcre-cpp
, sqlite
, libical
, neon
, xmlrpc_c
, boost
# gui/gtk related
, gtk3
, libnotify
, dbus-glib
, libsecret
# For gnome-bluetooth
, gnome3
# An attribute set of the features one would like to compile
, features ? {
    # The tests fail so we disable them here as well
    unit-tests = false;
    integration-tests = false;
    # we `--enable-libcurl`, and not `--enable-libsoup`
    libcurl = true;
    bluetooth = true;
    gui = "gtk";
    gtk = "3";
    core = true;
    cmdline = true;
    local-sync = true;
    # If it's a string then enableFeatureAs is used
    dbus-service = "syncevo-dbus-server";
    notify = true;
    # Otherwise it fails with an error saying bluetooth-plugin.h wasn't found.
    gnome-bluetooth-panel-plugin = false;
    gnome-keyring = true;
    # Phone Book Access Protocol (PBAP) based backend
    pbap = true;
    # WebDAV based backends (CalDAV)
    dav = true;
    # XMLRPC-based backend
    xmlrpc = true;
    # Enabling the following features requires libraries not yet packaged in
    # Nixpkgs. Upstream URLS are:
    #
    # - https://wiki.gnome.org/Projects/Folks - For libfolks-eds
    # - https://developer.gnome.org/libebook/
    # - https://developer.gnome.org/libecal/
    # - https://gitlab.gnome.org/GNOME/evolution-activesync
    #
    activesync = false;
    dbus-service-pim = false;
    ebook = false;
    ecal = false;
  }
}:

let
  # All of these go eventually to buildInputs, not native.
  featuresDeps = {
    libcurl = [ curl ];
    bluetooth = [ bluez openobex ];
    gnome-bluetooth-panel-plugin = [ gnome3.gnome-bluetooth ];
    gui = [ gtk3 dbus-glib ];
    # If it's a string then enableFeatureAs is used
    notify = [ libnotify ];
    # Otherwise it fails with an error saying bluetooth-plugin.h wasn't found.
    gnome-keyring = [ libsecret ];
    # WebDAV based backends (CalDAV)
    dav = [ libical neon ];
    # XMLRPC-based backend
    xmlrpc = [ xmlrpc_c ];
  };
  featuresBuildInputs = lib.concatLists (
    lib.mapAttrsToList (
      feat: enabled:
        if (builtins.typeOf enabled) == "string" then
          lib.optionals true (featuresDeps."${feat}" or [])
        else
          lib.optionals enabled (featuresDeps."${feat}" or [])
      ) features
    )
  ;
  configureFlags = lib.mapAttrsToList (
    feat: enabled:
    if (builtins.typeOf enabled) == "string" then
      lib.strings.enableFeatureAs true feat enabled
    else
      lib.strings.enableFeature enabled feat
  ) features;
in
stdenv.mkDerivation rec {
  pname = "syncevolution";
  version = "1.5.3";

  src = fetchurl {
    url = "https://download.01.org/syncevolution/syncevolution/sources/syncevolution-${version}.tar.gz";
    sha256 = "1h33x1zackfq6x6sb94s19wa97fnd6g4wrsmibmq4xxw17d5y6g1";
  };

  postConfigure = ''
    patchShebangs test/*.py test/synccompare.pl build/gen-changelog.pl build/source2html.py
  '';

  nativeBuildInputs = [
    pkg-config
    intltool
    # To validate the D-Bus service file via `xsltproc`
    libxslt
    # To run some scripts during build
    (python2.withPackages(ps: with ps; [
      pygments
    ]))
    perl
    # To debug build
    breakpointHook
  ];

  buildInputs = [
    boost
    pcre-cpp
    sqlite
  ] ++ featuresBuildInputs;

  inherit configureFlags;

  # Tests fail due to:
  #
  #   make[2]: *** No rule to make target 'test/__init__.py', needed by 'all-am'.  Stop.
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Synchronizes personal information management (PIM) data via various protocols (SyncML, CalDAV/CardDAV, ActiveSync)";
    homepage = "https://syncevolution.org/";
    license = licenses.lgpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ doronbehar ];
  };
}
