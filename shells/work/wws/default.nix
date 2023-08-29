{
  lib,
  mkShell,
  clang,
  openssl,
  pkg-config,
  stdenv,
  darwin,
  iconv,
}:
mkShell {
  nativeBuildInputs =
    [clang pkg-config protobuf openssl]
    ++ lib.optionals stdenv.isDarwin [darwin.apple_sdk.frameworks.Security iconv];
}
