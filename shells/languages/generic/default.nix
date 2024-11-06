{
  mkShell,
  pkgs,
  devGenericTools,
}:
mkShell {buildInputs = with pkgs; [autoconf automake clang cmake openssl] ++ devGenericTools;}
