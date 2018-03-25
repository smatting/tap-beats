let
    pkgs = import <nixpkgs> {};

    jobs = rec {
        tap-beats = import ./package.nix {};
    };
in
    jobs