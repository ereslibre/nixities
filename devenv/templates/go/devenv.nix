{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  languages.go.enable = true;

  packages = with pkgs; [alejandra just];

  pre-commit.hooks.gofmt.enable = true;
}
