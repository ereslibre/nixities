{
  mkShell,
  cabal-install,
  ghc,
  zlib,
}:
mkShell {buildInputs = [cabal-install ghc zlib];}
