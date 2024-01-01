{
  description = "Elm nixity";

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
          }: {
            env = {
              # `elm-land server` uses this envvar for setting up
              # listener
              HOST = "0.0.0.0";
            };
            languages.elm.enable = true;
            packages =
              # We require these binaries to interact with their CLI
              (with pkgs.elmPackages; [elm-land elm-review elm-test])
              ++ (with pkgs; [just]);
            pre-commit.hooks = {
              elm-format.enable = true;
              elm-review.enable = false;
              elm-test.enable = false;
            };
            scripts = {
              init.exec = ''
                mkdir .app
                ${pkgs.elmPackages.elm-land}/bin/elm-land init .app
                cat .app/.gitignore >> .gitignore
                rm .app/.gitignore
                mv .app/{.*,*} .
                rmdir .app
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
