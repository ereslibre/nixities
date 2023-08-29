{
  lib,
  mkShell,
  clang,
  cmake,
  openssl,
  pkg-config,
  protobuf,
  stdenv,
}:
mkShell {
  nativeBuildInputs = [clang cmake pkg-config protobuf openssl];
}
