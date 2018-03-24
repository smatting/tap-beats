{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc841" }:
let
  inherit (nixpkgs) pkgs;
  ghc = pkgs.haskell.packages.${compiler}.ghcWithPackages (ps: with ps; [
          sdl2
        ]);
in
pkgs.stdenv.mkDerivation {
  name = "my-haskell-env-0";
  buildInputs = [ ghc pkgs.cabal-install ];
  shellHook = "eval $(egrep ^export ${ghc}/bin/ghc)";
}