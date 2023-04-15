{ lib, pkgs, stdenv }:
let
  pname = "wasi-sdk";
  version = "19";
in pkgs.stdenv.mkDerivation {
  inherit pname version;

  sourceRoot = "${pname}-${version}.0";
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  nativeBuildInputs =
    lib.optional stdenv.isLinux (with pkgs; [ autoPatchelfHook pkg-config ]);
  buildInputs = lib.optional stdenv.isLinux (with pkgs; [ gcc-unwrapped ]);

  installPhase = ''
    mkdir -p $out/{bin,lib,share}
    mv bin/* $out/bin/
    mv lib/* $out/lib/
    mv share/* $out/share/
  '';

  src = let
    mapSystem = system:
      if system == "x86_64-linux" then {
        tarballSuffix = "linux";
        hash = "sha256-2QCryCbuwZVbmv0lDnzCSWM4q79sRA2GoxPAbkIIP6E=";
      } else {
        tarballSuffix = "macos";
        hash = "sha256-LCkIDzMNIukPNjF8oFWt+LBUKsgkcO/dRUx0Fv+gpDA=";
      };
  in (if builtins.elem stdenv.hostPlatform.system [
    "x86_64-linux"
    "x86_64-darwin"
  ] then
    let system = mapSystem stdenv.hostPlatform.system;
    in pkgs.fetchurl {
      url =
        "https://github.com/WebAssembly/${pname}/releases/download/${pname}-${version}/${pname}-${version}.0-${system.tarballSuffix}.tar.gz";
      hash = system.hash;
    }
  else
    throw "unsupported system");

  meta = { platforms = [ "x86_64-linux" "x86_64-darwin" ]; };
}
