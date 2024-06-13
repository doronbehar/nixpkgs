{ lib
, stdenv
, libsass
, nodejs
, fetchFromGitHub
, fetchYarnDeps
, yarnConfigHook
, yarnBuildHook
, npmHooks
, writeScriptBin
, nixosTests
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lemmy-ui";
  version = "0.19.3";

  src = fetchFromGitHub {
    owner = "LemmyNet";
    repo = "lemmy-ui";
    rev = "refs/tags/${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-6GGiKCNL0PALdz0W0d1OOPyMIA5kaoL3148j9GWzrMM=";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-UQ+B2vF34L+HuisyO7wdW2zCfEEGa8YdnoaB4jHi+DY=";
  };
  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
    # Emulate a git executable in $PATH, for upstream's git rev-parse --short
    # HEAD command used in package.json
    (writeScriptBin "git" ''
      echo ${finalAttrs.src.rev}
    '')
  ];

  buildInputs = [ libsass ];

  yarnBuildScript = "build:prod";

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -R ./dist $out

    runHook postInstall
  '';

  passthru.tests.lemmy-ui = nixosTests.lemmy;

  meta = with lib; {
    description = "Building a federated alternative to reddit in rust";
    homepage = "https://join-lemmy.org/";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ happysalada billewanick ];
    inherit (nodejs.meta) platforms;
  };
})
