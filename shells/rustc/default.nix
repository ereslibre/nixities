{
  mkShell,
  clang,
  cmake,
  ninja,
  python3,
}:
mkShell {buildInputs = [clang cmake ninja pkg-config python3];}
