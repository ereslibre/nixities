{
  description = "Nixity";

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
    # Fix issue with devenv-up missing with flakes: https://github.com/cachix/devenv/issues/756
    packages = eachSystem (system: {
      devenv-up = self.devShells.${system}.default.config.procfileScript;
    });
    devShells = eachSystem (system: let
      pkgs = import nixities.nixpkgs {inherit system;};
    in {
      # The default devShell
      default = devenv.lib.mkShell {
        inherit pkgs;
        inputs.nixpkgs = nixities.nixpkgs;
        modules = [
          ({pkgs, ...}: {
            # https://devenv.sh/reference/options/
            packages = with pkgs; [alejandra just];
            # languages.cplusplus.enable = true;
            # pre-commit.hooks = {
            #   clang-format.enable = true;
            # };
            # enterShell = ''
            #   hello
            # '';
          })
        ];
      };
      # Example of another devShell directly forwarded from the
      # devShells that nixities exposes
      # inherit (nixities.devShells.${system}) wasm;
    });
  };
}
