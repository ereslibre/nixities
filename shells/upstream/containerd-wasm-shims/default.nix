{
  mkShell,
  pkgs,
}:
mkShell {
  nativeBuildInputs = with pkgs; [clang cmake containerd openssl pkg-config protobuf];
}
