{ mkDerivation
, lib
, fetchFromGitHub
, nix-update-script
, pkgconfig
, gtk3
, glib
, qtbase
, qmake
, qtx11extras
, adwaita-qt
, pantheon
, substituteAll
, gsettings-desktop-schemas
}:

mkDerivation rec {
  pname = "qgnomeplatform";
  version = "0.6.90";

  src = fetchFromGitHub {
    owner = "FedoraQt";
    repo = "QGnomePlatform";
    rev = version;
    sha256 = "rdjk2tfEh2YA084hsq5bhErtsNSFWfQBolXy19/ABdY=";
  };

  patches = [
    # Hardcode GSettings schema path to avoid crashes from missing schemas
    (substituteAll {
      src = ./hardcode-gsettings.patch;
      gds_gsettings_path = glib.getSchemaPath gsettings-desktop-schemas;
    })
  ];

  nativeBuildInputs = [
    pkgconfig
    qmake
  ];

  buildInputs = [
    glib
    gtk3
    qtbase
    qtx11extras
    adwaita-qt
  ];

  postPatch = ''
    # Fix plugin dir
    substituteInPlace decoration/decoration.pro \
      --replace "\$\$[QT_INSTALL_PLUGINS]" "$out/$qtPluginPrefix"
    substituteInPlace theme/theme.pro \
      --replace "\$\$[QT_INSTALL_PLUGINS]" "$out/$qtPluginPrefix"
  '';

  passthru = {
    updateScript = nix-update-script {
      attrPath = pname;
    };
  };

  meta = with lib; {
    description = "QPlatformTheme for a better Qt application inclusion in GNOME";
    homepage = "https://github.com/FedoraQt/QGnomePlatform";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ worldofpeace ];
    platforms = platforms.linux;
  };
}
