{ tectonic-unwrapped, fetchFromGitHub, rustPlatform }:

let
  src = fetchFromGitHub {
    owner = "let-def";
    repo = "tectonic";
    rev = "b38cb3b2529bba947d520ac29fbb7873409bd270";
    hash = "sha256-ap7fEPHsASAphIQkjcvk1CC7egTdxaUh7IpSS5os4W8=";
    fetchSubmodules = true;
  };
in tectonic-unwrapped.overrideAttrs (old: {
  pname = "texpresso-tonic";
  version = "0.15.0-unstable-2024-04-18";
  inherit src;
  # Not simply setting a cargoHash, as that won't be picked up by the
  # buildRustPackage, and the old one will be used instead. This attribute has
  # precedence over the fixed-output derivation that can buildRustPackage
  # builds by itself if only cargoHash is specified.
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  cargoHash = null;
  cargoPatches = null;
  # binary has a different name, bundled tests won't work
  doCheck = false;
  postInstall = ''
    ${old.postInstall or ""}

    # Remove the broken `nextonic` symlink
    # It points to `tectonic`, which doesn't exist because the exe is
    # renamed to texpresso-tonic
    rm $out/bin/nextonic
  '';
  meta.mainProgram = "texpresso-tonic";
})
