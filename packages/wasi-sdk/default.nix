{ lib, pkgs, stdenv }:
let
  pname = "wasi-sdk";
  version = "20";
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
        hash = "sha256-cDATnUlaGfvsy5RJFQwrFTHhXY+3RBmHKnGadYCq0Pk=";
      } else {
        tarballSuffix = "macos";
        hash = "sha256-j+okNPBQYuo22WBHi6hrmhcMxxheB2W/tJ0kuymjlGY=";
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
