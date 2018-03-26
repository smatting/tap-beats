let
    pkgs = import <nixpkgs> {};

    jobs = rec {
        tap-beats = import ./default.nix {};
    };
in
    jobs