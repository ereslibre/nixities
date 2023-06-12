{
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
      pkgs = nixities.legacyPackages.${system};
    in {
      # The default devShell
      default = devenv.lib.mkShell {
        inherit pkgs;
        inputs.nixpkgs = nixities.nixpkgs;
        modules = [
          ({pkgs, ...}: {
            # https://devenv.sh/reference/options/
            packages = with pkgs; [hello];

            enterShell = ''
              hello
            '';
          })
        ];
      };
      # Example of another devShell directly forwarded from the
      # devShells that nixities exposes
      inherit (nixities.devShells.${system}) wasm;
    });
  };
}
