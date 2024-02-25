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
    forEachSystem = nixities.nixpkgs.lib.genAttrs (import systems);
  in {
    # Fix issue with devenv-up missing with flakes: https://github.com/cachix/devenv/issues/756
    packages = forEachSystem (system: {
      devenv-up = self.devShells.${system}.default.config.procfileScript;
    });
    devShells = forEachSystem (system: let
      pkgs = import nixities.nixpkgs {inherit system;};
    in {
      default = devenv.lib.mkShell {
        inherit pkgs;
        inputs.nixpkgs = nixities.nixpkgs;
        modules = [
          ({
            pkgs,
            lib,
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
          })
        ];
      };
    });
  };
}
