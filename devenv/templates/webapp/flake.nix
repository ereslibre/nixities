{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    self,
    nixpkgs,
    devenv,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = forEachSystem (system: {
      devenv-up = self.devShells.${system}.default.config.procfileScript;
    });

    devShells =
      forEachSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {imports = [./backend ./frontend];}
            {
              enterShell = ''
                cat <<'EOF' | ${pkgs.bat}/bin/bat --language=markdown
                  # Welcome to a new webapp!

                  ## Init

                  Inspect the backend, and create a frontend --if applies.--

                  In order to create a frontend, run:
                  - `pushd frontend && elm-init && popd`

                  Now, you can start the devenv environment: `devenv up`.
                EOF
              '';

              packages = with pkgs; [alejandra just];

              processes = {
                backend.exec = "cd backend && db-setup && cargo run";
              };
            }
          ];
        };
      });
  };
}
