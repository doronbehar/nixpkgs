{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_20,
  node-gyp,
  libudev-zero,
  replaceVars,
  electron,
}:

let
  buildNpmPackage' = buildNpmPackage.override {
    nodejs = nodejs_20;
  };
  node-gyp' = node-gyp.override {
    nodejs = nodejs_20;
  };
in
buildNpmPackage' rec {
  pname = "balena-etcher";
  version = "2.1.4";

  src = fetchFromGitHub {
    owner = "balena-io";
    repo = "etcher";
    rev = "v${version}";
    hash = "sha256-JQFdAWT12FdT5Y7XC9UY6D3TLhFG5QjnZhC8PGdK0vc=";
  };

  npmDepsHash = "sha256-Ae0yMz0p7YBZrYTibKyA1TqFT7LubigRkalecImunBI=";

  patches = [
    (replaceVars ./fix-electron-forge-issues.patch {
      nodejsBin = lib.getExe nodejs_20;
    })
  ];

  postPatch = ''
    ln -s npm-shrinkwrap.json package-lock.json
  '';
  makeCacheWritable = true;

  nativeBuildInputs = [
    node-gyp'
  ];

  buildInputs = [
    libudev-zero
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  };
  preBuild = ''
    rm -r node_modules/electron
    cp -r ${electron.dist} node_modules/electron
    chmod -R u+w node_modules/electron
  '';
  npmBuildScript = "package";

  meta = {
    description = "Flash OS images to SD cards & USB drives, safely and easily";
    homepage = "https://github.com/balena-io/etcher";
    changelog = "https://github.com/balena-io/etcher/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "etcher";
    platforms = lib.platforms.all;
  };
}
