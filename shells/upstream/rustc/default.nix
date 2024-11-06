{
  mkShell,
  pkgs,
  devGenericTools,
}:
mkShell {
  buildInputs = with pkgs; [clang cmake ninja openssl python3] ++ devGenericTools;
}
