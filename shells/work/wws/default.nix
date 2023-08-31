{
  lib,
  mkShell,
  clang,
  openssl,
  openvino,
  pkg-config,
  python3,
  stdenv,
  darwin,
  iconv,
}:
mkShell {
  nativeBuildInputs =
    [clang pkg-config openssl]
    ++ lib.optionals stdenv.isLinux [python3]
    ++ lib.optionals stdenv.isDarwin [darwin.apple_sdk.frameworks.Security iconv];

  shellHook = lib.optionalString stdenv.isLinux ''
    . ${openvino}/setupvars.sh
  '';
}
