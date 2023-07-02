{
  mkShell,
  clang,
  cmake,
  devGenericTools,
  ninja,
  python3,
}:
mkShell {buildInputs = [clang cmake ninja openssl python3] ++ devGenericTools;}
