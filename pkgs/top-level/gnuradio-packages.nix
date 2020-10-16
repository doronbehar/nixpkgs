{ lib
, stdenv
, newScope
, gnuradio # unwrapped gnuradio
}:

lib.makeScope newScope ( self:

let
  callPackage = self.callPackage;

  # Modeled after qt's
  mkDerivationWith = import ../development/gnuradio-modules/mkDerivation.nix {
    inherit stdenv;
    unwrapped = gnuradio;
  };
  mkDerivation = mkDerivationWith stdenv.mkDerivation;

in {

  inherit callPackage mkDerivationWith mkDerivation;

  ### Packages

  inherit gnuradio;

  osmosdr = callPackage ../development/gnuradio-modules/osmosdr/default.nix { };

  ais = callPackage ../development/gnuradio-modules/ais/default.nix { };

  gsm = callPackage ../development/gnuradio-modules/gsm/default.nix { };

  nacl = callPackage ../development/gnuradio-modules/nacl/default.nix { };

  rds = callPackage ../development/gnuradio-modules/rds/default.nix { };

  limesdr = callPackage ../development/gnuradio-modules/limesdr/default.nix { };

})
