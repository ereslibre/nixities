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
    devShells = forEachSystem (system: let
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
            languages.python = {
              enable = true;
              package = pkgs.python311;
            };
            packages = with pkgs; [
              python311Packages.pip
            ];
            pre-commit.hooks = {
              black.enable = true;
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
