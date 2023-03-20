{ fetchurl, stdenv, autoPatchelfHook, zlib }:

stdenv.mkDerivation rec {
  pname = "wws";
  version = "1.0.1";
  src = fetchurl {
    url =
      "https://github.com/vmware-labs/wasm-workers-server/releases/download/v1.0.1/wws-linux-musl-x86_64.tar.gz";
    hash = "sha256-9bzafW7dmj3lkk3G43/06Nr+ANIvdTzMCMAcTGuit/o=";
  };
  nativeBuildInputs = [ autoPatchelfHook ];
  sourceRoot = ".";
  dontBuild = true;
  dontConfigure = true;
  installPhase = ''
    mkdir -p $out/bin
    mv wws $out/bin
  '';
}
