{
  description = "Python nixity";

  inputs = {
    devenv.url = "github:cachix/devenv";
    nixities.url = "github:ereslibre/nixities";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    devenv,
    nixities,
    systems,
    ...
  } @ inputs: let
    eachSystem = nixities.nixpkgs.lib.genAttrs (import systems);
  in {
    devShells = eachSystem (system: let
      pkgs = import nixities.nixpkgs {inherit system;};
    in {
      # The default devShell
      default = devenv.lib.mkShell {
        inherit pkgs;
        inputs.nixpkgs = nixities.nixpkgs;
        modules = [
          ({
            pkgs,
            lib,
            ...
          }: let
            pythonPackages = pkgs.python3Packages;
          in {
            enterShell = ''
              export PYTHONPATH="$HOME/.pip:$PYTHONPATH";
            '';
            languages.python = {
              enable = true;
              package = pythonPackages.python;
            };
            packages =
              (with pkgs; [stdenv.cc.cc.lib])
              ++ (with pythonPackages; [
                pip
                venvShellHook
              ]);
            pre-commit.hooks = {
              black.enable = true;
            };
            scripts = {
              pip-install.exec = ''
                ${pythonPackages.pip}/bin/pip install -r requirements.txt -t $HOME/.pip
              '';
            };
          })
        ];
      };
      # Example of another devShell directly forwarded from the
      # devShells that nixities exposes
      # inherit (nixities.devShells.${system}) wasm;
    });
  };
}
