{
  mkShell,
  alex,
  autoconf,
  automake,
  cabal-install,
  ghc,
  gmp,
  happy,
  ncurses,
  python3,
}:
mkShell {
  NIX_HARDENING_ENABLE = "";
  buildInputs = [alex autoconf automake cabal-install ghc gmp happy ncurses python3];
}
