{
  mkShell,
  pkgs,
}:
mkShell {
  buildInputs = with pkgs; [cabal-install ghc zlib];
}
