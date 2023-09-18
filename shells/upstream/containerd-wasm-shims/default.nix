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
}:
mkShell {
  nativeBuildInputs = [clang cmake containerd pkg-config protobuf openssl];
}
