{ mkDerivation, base, sdl2, stdenv }:
mkDerivation {
  pname = "tap-beats";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  enableSeparateDataOutput = true;
  executableHaskellDepends = [ base sdl2 ];
  license = stdenv.lib.licenses.mit;
}
