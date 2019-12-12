{ stdenv
, fetchurl
, qt4
, qmake4Hook
, exempi
, pkg-config
# runtime dependencies
, poppler_utils
, ghostscriptX
, pdflatex # The package that in it's bin/ there'll be an executable pdflatex
}:

stdenv.mkDerivation rec {
  version = "0.7.1";
  pname = "equalx";

  src = fetchurl {
    url = "https://netix.dl.sourceforge.net/project/equalx/EqualX-0.7/equalx-0.7.1.tar.gz";
    sha256 = "12qz36hyn7kqs0d5wzahd390qsvapxhl3grr7blfih3b420faqkz";
  };

  buildInputs = [
    qt4
    exempi
    # runtime
    poppler_utils
    pdflatex
  ];
  nativeBuildInputs = [
    pkg-config
    qmake4Hook
  ];
  # qmakeFlags = [
    # "-makefile"
    # "-set target.path=${placeholder "out"}"
    # "equalx.pro"
  # ];

  prePatch = ''
    for f in include/defines.h ui/dialogPreferences.ui; do
      substituteInPlace $f \
        --replace /usr/bin/pdftocairo "${poppler_utils}/bin/pdftocairo" \
        --replace /usr/bin/pdflatex "${pdflatex}/bin/pdflatex" \
        --replace /usr/bin/gs "${ghostscriptX}/bin/gs"
    done
    grep bin/pdflatex include/defines.h ui/dialogPreferences.ui
    grep bin/pdftocairo include/defines.h ui/dialogPreferences.ui
    grep bin/gs include/defines.h ui/dialogPreferences.ui
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp equalx -t $out/bin
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    homepage = "http://equalx.sourceforge.net/index.html";
    description = "A helpful graphical application to LaTeX programs intended for writing equations, but is not a full editor";
    license = licenses.gpl3;
    maintainers = with maintainers; [ doronbehar ];
    platforms = platforms.linux;
  };
}
