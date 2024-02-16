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
          ({pkgs, ...}: {
            packages = with pkgs; [alejandra just];
            scripts = {
              start-notebook.exec = "nix run . -- --ip 0.0.0.0";
            };
            enterShell = ''
              cat <<"EOF" | ${pkgs.bat}/bin/bat --decorations=never --language=markdown
              # Instructions
              * Start the Jupyter Notebook: `start-notebook`
              EOF
            '';
          })
        ];
      };
    });

    packages = eachSystem (system: let
      # Fix issue with devenv-up missing with flakes: https://github.com/cachix/devenv/issues/756
      devenv-up = self.devShells.${system}.default.config.procfileScript;
      jupyterlab = jupyenv.lib.${system}.mkJupyterlabNew ({...}: {
        inherit (nixities) nixpkgs;
        imports = [
          ({...}: {
            kernel.python.minimal.enable = true;

            kernel.python.science = {
              enable = true;
              extraPackages = ps: (with ps; [
                matplotlib
                numpy
                pandas
                pytools
                scikit-learn
                scipy
                torch-bin
              ]);
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
