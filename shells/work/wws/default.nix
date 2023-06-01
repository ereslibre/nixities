{
  mkShell,
  pkg-config,
  clang,
  openssl,
}:
mkShell {nativeBuildInputs = [pkg-config clang openssl];}
