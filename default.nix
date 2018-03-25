{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc841" }:
nixpkgs.haskell.lib.justStaticExecutables(nixpkgs.pkgs.haskell.packages.${compiler}.callPackage ./package.nix { })


#   pandoc = haskell.lib.overrideCabal (haskell.lib.justStaticExecutables haskellPackages.pandoc) (drv: {
#     configureFlags = drv.configureFlags or [] ++ ["-fembed_data_files"];
#     buildDepends = drv.buildDepends or [] ++ [haskellPackages.file-embed];
#   });