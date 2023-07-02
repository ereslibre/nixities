{
  mkShell,
  clang,
  cmake,
  ninja,
  python3,
}:
mkShell {buildInputs = [clang cmake ninja python3] ++ devGenericTools;}
