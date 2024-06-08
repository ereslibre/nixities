{
  mkShell,
  clang,
  cmake,
  ninja,
  openssl,
  python3,
  devGenericTools,
}:
mkShell {
  buildInputs = [clang cmake ninja openssl python3] ++ devGenericTools;
}
