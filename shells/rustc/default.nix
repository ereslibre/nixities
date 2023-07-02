{
  mkShell,
  clang,
  cmake,
  devGenericTools,
  ninja,
  python3,
}:
mkShell {buildInputs = [clang cmake ninja python3] ++ devGenericTools;}
