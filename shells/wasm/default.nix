{
  lib,
  mkShell,
  allWasmTools,
  stdenv,
  pkgs,
}:
mkShell {
  buildInputs = allWasmTools;
  nativeBuildInputs = with pkgs; [iconv openssl] ++ (lib.optionals stdenv.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [Security SystemConfiguration]));
}
