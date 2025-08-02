{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  languages.go.enable = true;

  packages = with pkgs; [alejandra just];

  git-hooks.hooks.gofmt.enable = true;
}
