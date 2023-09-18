{
  lib,
  mkShell,
  clang,
  cmake,
  containerd,
  openssl,
  pkg-config,
  protobuf,
  stdenv,
  zlib,
}:
mkShell {
  LD_LIBRARY_PATH = "${zlib}/lib:$LD_LIBRARY_PATH";
  nativeBuildInputs = [clang cmake containerd pkg-config protobuf openssl];
}
