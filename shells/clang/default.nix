{
  mkShell,
  autoconf,
  automake,
  clang,
  cmake,
  devGenericTools,
}:
mkShell {buildInputs = [autoconf automake clang cmake] ++ devGenericTools;}
