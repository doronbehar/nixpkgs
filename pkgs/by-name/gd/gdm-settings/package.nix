{
  lib,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  appstream,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  gobject-introspection,
  wrapGAppsHook4,
  glib,
  python3,
  gtk4,
  libadwaita,
  gnome,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gdm-settings";
  version = "4.4";
  # Built with meson
  format = "other";

  src = fetchFromGitHub {
    owner = "gdm-settings";
    repo = "gdm-settings";
    rev = "v${version}";
    hash = "sha256-3Te8bhv2TkpJFz4llm1itRhzg9v64M7Drtrm4s9EyiQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    glib
    appstream
    blueprint-compiler
    appstream-glib
    desktop-file-utils
    gobject-introspection
    wrapGAppsHook4
    python3.pkgs.wrapPython
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];
  propagatedBuildInputs = [
    python3.pkgs.pygobject3
  ];
  dontWrapGApps = true; # prevent double wrapping
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = {
    description = "A settings app for GNOME's Login Manager, GDM";
    homepage = "https://github.com/gdm-settings/gdm-settings";
    changelog = "https://github.com/gdm-settings/gdm-settings/blob/${src.rev}/NEWS";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "gdm-settings";
    inherit (gnome.gdm.meta) platforms;
  };
}
