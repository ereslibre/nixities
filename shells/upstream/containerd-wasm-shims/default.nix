{
  mkShell,
  clang,
  cmake,
  containerd,
  openssl,
  pkg-config,
  protobuf,
}:
mkShell {
  nativeBuildInputs = [clang cmake containerd openssl pkg-config protobuf];
}
