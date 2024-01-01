{
  description = "OCI container";

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
  }: let
    eachSystem = nixities.nixpkgs.lib.genAttrs (import systems);
  in {
    devShells = eachSystem (system: let
      pkgs = import nixities.nixpkgs {inherit system;};
    in {
      default = devenv.lib.mkShell {
        inherit pkgs;
        inputs.nixpkgs = nixities.nixpkgs;
        modules = [
          ({pkgs, ...}: {
            packages = with pkgs; [just];
          })
        ];
      };
    });

    packages = eachSystem (system: let
      pkgs = import nixities.nixpkgs {inherit system;};
    in {
      default = pkgs.dockerTools.buildImage {
        name = "hello-oci-runtime";
        config = {
          Cmd = ["${pkgs.hello}/bin/hello"];
        };
      };
    });
  };
}
