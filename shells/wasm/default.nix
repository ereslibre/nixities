{
  lib,
  mkShell,
  allWasmTools,
  stdenv,
  darwin,
  iconv,
  openssl,
}:
mkShell {
  buildInputs = allWasmTools;
  nativeBuildInputs = [openssl] ++ (lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [Security SystemConfiguration] ++ [iconv]));
}
