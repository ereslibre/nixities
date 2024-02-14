{
  description = "NixOS container";

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
            packages = with pkgs; [alejandra just];
            enterShell = ''
              cat <<"EOF" | ${pkgs.bat}/bin/bat --decorations=never --language=markdown
              # Instructions
              * Build for x86_64-linux: just build x86_64-linux
              EOF
            '';
          })
        ];
      };
    });

    nixosConfigurations.container = eachSystem (system: let
      pkgs = import nixities.nixpkgs {inherit system;};
    in
      nixities.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({pkgs, ...}: {
            boot.isContainer = true;

            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision = nixities.nixpkgs.lib.mkIf (self ? rev) self.rev;

            # Network configuration.
            networking.useDHCP = false;
            networking.firewall.allowedTCPPorts = [80];

            # Enable a web server.
            services.httpd = {
              enable = true;
              adminAddr = "some@example.com";
            };

            system.stateVersion = "23.11";
          })
        ];
      });
  };
}
