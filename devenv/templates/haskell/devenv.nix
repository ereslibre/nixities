{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  packages = with pkgs; [alejandra just];

  languages.haskell = {
    enable = true;
    package = pkgs.haskell.compiler.ghc946;
  };

  pre-commit.hooks.ormolu.enable = true;
}
