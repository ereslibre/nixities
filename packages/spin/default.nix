{ fetchurl, stdenv, autoPatchelfHook, zlib }:

stdenv.mkDerivation rec {
  pname = "spin";
  version = "0.10.1";
  src = fetchurl {
    url =
      "https://github.com/fermyon/spin/releases/download/v0.10.1/spin-v0.10.1-linux-amd64.tar.gz";
    hash = "sha256-EFBUM1/Xaz0qG3anBdvbO4PX5Ak7MCp4Fs5/kiiT8p0=";
  };
  buildInputs = [ zlib ];
  nativeBuildInputs = [ autoPatchelfHook ];
  sourceRoot = ".";
  dontBuild = true;
  dontConfigure = true;
  installPhase = ''
    mkdir -p $out/bin
    mv spin $out/bin
  '';
}
