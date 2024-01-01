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

    microvms = eachSystem (hostSystem: (eachSystem (guestSystem: {
      microvm = nixities.nixpkgs.lib.nixosSystem {
        system = hostSystem;
        modules = let
          pkgs = import nixities.nixpkgs (nixities.nixpkgs.lib.recursiveUpdate {
              system = hostSystem;
            } (
              if guestSystem != hostSystem
              then {crossSystem.config = guestSystem;}
              else {}
            ));
        in
          (
            if guestSystem != hostSystem
            then [{nixpkgs.crossSystem.config = guestSystem;}]
            else []
          )
          ++ [
            microvm.nixosModules.microvm
            {
              microvm = {
                cpu =
                  if guestSystem == "aarch64-linux"
                  then "cortex-a53"
                  else null;
                hypervisor = "qemu";
              };
              environment.systemPackages = with pkgs; [cowsay htop];
              services.getty.autologinUser = "root";
              system.stateVersion = "23.11";
            }
          ];
      };
    })));
  };
}
