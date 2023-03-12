{ pkgs }:
let
  pname = "wasi-sdk";
  version = "19";
in pkgs.stdenv.mkDerivation {
  inherit pname version;

  sourceRoot = "${pname}-${version}.0";
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  nativeBuildInputs = with pkgs; [ autoPatchelfHook ];

  installPhase = ''
    mkdir -p $out/{bin,lib,share}
    mv bin/* $out/bin/
    mv lib/* $out/lib/
    mv share/* $out/share/
  '';

  src = pkgs.fetchurl {
    url =
      "https://github.com/WebAssembly/${pname}/releases/download/${pname}-${version}/${pname}-${version}.0-linux.tar.gz";
    hash = "sha256-2QCryCbuwZVbmv0lDnzCSWM4q79sRA2GoxPAbkIIP6E=";
  };

  meta = { platforms = [ "x86_64-linux" ]; };
}
