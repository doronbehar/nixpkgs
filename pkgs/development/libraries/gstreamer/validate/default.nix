{ stdenv
, fetchurl
, pkgconfig
, gstreamer
, gst-plugins-base
, python3
, gobject-introspection
, json-glib
}:

stdenv.mkDerivation rec {
  pname = "gst-validate";
  version = "1.18.0";

  src = fetchurl {
    url = "${meta.homepage}/src/${pname}/${pname}-${version}.tar.xz";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [
    pkgconfig
    gobject-introspection
  ];

  buildInputs = [
    python3
    json-glib
  ];

  propagatedBuildInputs = [
    gstreamer
    gst-plugins-base
  ];

  meta = with stdenv.lib; {
    description = "Integration testing infrastructure for the GStreamer framework";
    homepage = "https://gstreamer.freedesktop.org";
    license = licenses.lgpl2Plus;
    platforms = platforms.unix;
  };
}
