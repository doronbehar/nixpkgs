{ lib
, stdenv
, fetchurl
, jre
, unzip
, makeWrapper
, makeDesktopItem
}:

let
  desktopItem = makeDesktopItem {
    name = "ImageJ";
    desktopName = "ImageJ";
    icon = "imagej";
    categories = "Science;Utility;Graphics;";
    exec = "imagej";
  };
  icon = fetchurl {
    url = "https://imagej.net/media/icons/imagej.png";
    sha256 = "sha256-nU2nWI1wxZB/xlOKsZzdUjj+qiCTjO6GwEKYgZ5Risg=";
  };
in stdenv.mkDerivation rec {
  pname = "imagej";
  version = "153";

  src = fetchurl {
    url = "https://wsr.imagej.net/distros/cross-platform/ij${version}.zip";
    sha256 = "sha256-MGuUdUDuW3s/yGC68rHr6xxzmYScUjdXRawDpc1UQqw=";
  };
  nativeBuildInputs = [ makeWrapper unzip ];
  passthru = {
    inherit jre;
  };

  # JAR files that are intended to be used by other packages
  # should go to $out/share/java.
  # (Some uses ij.jar as a library not as a standalone program.)
  installPhase = ''
    mkdir -p $out/share/java
    # Read permisssion suffices for the jar and others.
    # Simple cp shall clear suid bits, if any.
    cp ij.jar $out/share/java
    cp -dR luts macros plugins $out/share
    mkdir $out/bin
    makeWrapper ${jre}/bin/java $out/bin/imagej \
      --add-flags "-jar $out/share/java/ij.jar -ijpath $out/share"
  '' + lib.optionalString stdenv.isLinux ''
    install -Dm644 ${icon} $out/share/icons/hicolor/128x128/apps/imagej.png
    install -Dm644 ${desktopItem}/share/applications/ImageJ.desktop $out/share/applications/ImageJ.desktop
    substituteInPlace $out/share/applications/ImageJ.desktop \
      --replace Exec=imagej Exec=$out/bin/imagej
  '';
  meta = with lib; {
    homepage = "https://imagej.nih.gov/ij/";
    description = "Image processing and analysis in Java";
    longDescription = ''
      ImageJ is a public domain Java image processing program
      inspired by NIH Image for the Macintosh.
      It runs on any computer with a Java 1.4 or later virtual machine.
    '';
    license = licenses.publicDomain;
    platforms = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ yuriaisaka ];
  };
}
