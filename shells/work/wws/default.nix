{
  lib,
  mkShell,
  clang,
  openssl,
  openvino,
  pkg-config,
  stdenv,
  darwin,
  iconv,
}:
mkShell {
  nativeBuildInputs =
    [clang pkg-config openssl openvino]
    ++ lib.optionals stdenv.isDarwin [darwin.apple_sdk.frameworks.Security iconv];
}
