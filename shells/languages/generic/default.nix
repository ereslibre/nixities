{
  mkShell,
  autoconf,
  automake,
  clang,
  cmake,
  openssl,
  devGenericTools,
}:
mkShell {buildInputs = [autoconf automake clang cmake openssl] ++ devGenericTools;}
