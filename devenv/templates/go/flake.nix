{
  description = "Rust nixity";

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
            languages.go.enable = true;
            packages = with pkgs; [alejandra just openssl pkg-config];
            pre-commit.hooks.gofmt.enable = true;
          })
        ];
      };
      # Example of another devShell directly forwarded from the
      # devShells that nixities exposes
      # inherit (nixities.devShells.${system}) wasm;
    });
  };
}
