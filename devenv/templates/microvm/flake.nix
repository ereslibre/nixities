{
  description = "Micro VM";

  inputs = {
    devenv.url = "github:cachix/devenv";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixities";
    };
    nixities.url = "github:ereslibre/nixities";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    devenv,
    microvm,
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

    microvms = eachSystem (hostSystem: {
      host = eachSystem (guestSystem: {
        guest = nixities.nixpkgs.lib.nixosSystem {
          system = hostSystem;
          modules = let
            pkgs = import nixities.nixpkgs {
              system = hostSystem;
              crossSystem.config = guestSystem;
            };
          in [
            {nixpkgs.crossSystem.config = guestSystem;}
            microvm.nixosModules.microvm
            {
              microvm = {
                cpu = "cortex-a53";
                hypervisor = "qemu";
              };
              environment.systemPackages = with pkgs; [cowsay htop];
              services.getty.autologinUser = "root";
              system.stateVersion = "23.11";
            }
          ];
        };
      });
    });
  };
}
