{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc841" }:
(import ./default.nix { inherit nixpkgs compiler; }).env