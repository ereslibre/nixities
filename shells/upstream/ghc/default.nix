{
  mkShell,
  pkgs,
}:
mkShell {
  NIX_HARDENING_ENABLE = "";
  buildInputs = with pkgs; [alex autoconf automake cabal-install ghc gmp happy ncurses python3];
}
