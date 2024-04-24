{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  languages.python = {
    enable = true;
    poetry = {
      enable = true;
      activate.enable = true;
      install = {
        enable = true;
        allExtras = true;
        installRootPackage = true;
      };
    };
  };

  packages = with pkgs; [alejandra just];
}
