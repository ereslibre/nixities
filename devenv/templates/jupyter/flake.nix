{
  description = "Nixity with Jupyter notebook integration";

  inputs = {
    devenv.url = "github:cachix/devenv";
    jupyenv.url = "github:tweag/jupyenv";
    nixities.url = "github:ereslibre/nixities";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    devenv,
    jupyenv,
    nixities,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixities.nixpkgs.lib.genAttrs (import systems);
  in {
    devShells = forEachSystem (system: let
      pkgs = import nixities.nixpkgs {inherit system;};
    in {
      # The default devShell
      default = devenv.lib.mkShell {
        inherit pkgs;
        inputs.nixpkgs = nixities.nixpkgs;
        modules = [
          ({pkgs, ...}: {
            enterShell = ''
              cat <<"EOF" | ${pkgs.bat}/bin/bat --decorations=never --language=markdown
              # Instructions
              * Start the Jupyter Notebook: `nix run . -- --ip 0.0.0.0`
              EOF
            '';
          })
        ];
      };
    });

    packages = forEachSystem (system: let
      jupyterlab = jupyenv.lib.${system}.mkJupyterlabNew ({...}: {
        inherit (nixities) nixpkgs;
        imports = [
          ({...}: {
            kernel.python.minimal = {
              enable = true;
              extraPackages = ps: with ps; [pytools matplotlib numpy pandas scikit-learn];
            };
          })
        ];
      });
    in {
      inherit jupyterlab;
      default = jupyterlab;
    });

    apps.default = {
      program = "${self.packages.jupyterlab}/bin/jupyter-lab";
      type = "app";
    };
  };
}
