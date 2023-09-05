{
  mkShell,
  clang,
  cmake,
  devGenericTools,
  ninja,
  openssl,
  python3,
}:
mkShell {buildInputs = [clang cmake ninja openssl python3] ++ devGenericTools;}
