{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  languages = {
    c.enable = true;
    rust.enable = true;
  };

  packages = with pkgs; [alejandra just openssl pkg-config];

  git-hooks.hooks = {
    rustfmt.enable = true;
    clippy.enable = true;
  };
}
