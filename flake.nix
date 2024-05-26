{
  description = "nixities";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    flake-utils,
    microvm,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-cuda = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };
      wasmRuntimes = with pkgs; [wasmer wasmtime wavm];
      wasmGenericTools = with pkgs; [binaryen wabt wasm-tools];
      devGenericTools = with pkgs; [lldb pkg-config];
      allWasmTools = wasmGenericTools ++ wasmRuntimes ++ devGenericTools;
    in {
      packages = {
        cuda.ollama = pkgs-cuda.callPackage ./packages/ollama {};
        wasi-sdk-19 = pkgs.callPackage ./packages/wasi-sdk-19 {};
        wasi-sdk-20 = pkgs.callPackage ./packages/wasi-sdk-20 {};
        vms =
          nixpkgs.lib.mapAttrs
          (name: nixosDefinition: nixosDefinition.config.microvm.declaredRunner)
          self.outputs.nixosConfigurations.${system}.vms;
      };
      legacyPackages = pkgs;
      devShells = {
        default = self.devShells.${system}.nix;
        languages = {
          generic = pkgs.callPackage ./shells/languages/generic {inherit devGenericTools;};
        };
        misc = {
          demo-magic = pkgs.callPackage ./shells/misc/demo-magic {};
        };
        nix = pkgs.mkShell {buildInputs = with pkgs; [alejandra just];};
        wasi-sdk-19 = pkgs.callPackage ./shells/wasi-sdk {
          inherit allWasmTools;
          wasi-sdk = self.packages.${system}.wasi-sdk-19;
        };
        wasi-sdk-20 = pkgs.callPackage ./shells/wasi-sdk {
          inherit allWasmTools;
          wasi-sdk = self.packages.${system}.wasi-sdk-20;
        };
        wasm = pkgs.callPackage ./shells/wasm {inherit allWasmTools;};
        work = {
          mod-wasm = pkgs.callPackage ./shells/work/mod-wasm {};
          wasm-labs = pkgs.callPackage ./shells/work/wasm-labs {};
          wws = pkgs.callPackage ./shells/work/wws {};
          php = {
            native = pkgs.callPackage ./shells/work/php {};
            wasi-sdk-19 = pkgs.callPackage ./shells/work/php.wasi {
              inherit allWasmTools;
              wasi-sdk = self.packages.${system}.wasi-sdk-19;
            };
            wasi-sdk-20 = pkgs.callPackage ./shells/work/php.wasi {
              inherit allWasmTools;
              wasi-sdk = self.packages.${system}.wasi-sdk-20;
            };
          };
        };
        upstream = {
          containerd-wasm-shims = pkgs.callPackage ./shells/upstream/containerd-wasm-shims {};
          elm = pkgs.callPackage ./shells/upstream/elm {};
          rustc = pkgs.callPackage ./shells/upstream/rustc {inherit devGenericTools;};
          wasi-libc =
            pkgs.callPackage ./shells/upstream/wasi-libc {inherit allWasmTools;};
          wasi-vfs-19 = pkgs.callPackage ./shells/upstream/wasi-vfs {
            inherit allWasmTools;
            wasi-sdk = self.packages.${system}.wasi-sdk-19;
          };
          wasi-vfs-20 = pkgs.callPackage ./shells/upstream/wasi-vfs {
            inherit allWasmTools;
            wasi-sdk = self.packages.${system}.wasi-sdk-20;
          };
          zig = pkgs.callPackage ./shells/upstream/zig {};
        };
      };
      nixosConfigurations.vms = {
        generic-dev = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            microvm.nixosModules.microvm
            {
              microvm = {
                interfaces = [
                  {
                    type = "user";
                    id = "microvm-test";
                    mac = "02:00:00:00:00:01";
                  }
                ];
                hypervisor = "qemu";
              };
              systemd.services.run-script-at-init = {
                description = "A minimal example for a custom systemd service";
                wantedBy = ["multi-user.target"];
                # serviceConfig = {
                #   ExecStart = "/some/path";
                #   User = "root";
                #   Group = "root";
                # };
                script = ''
                  touch /root/hello-world
                '';
              };
              networking.hostName = "nixity-vm";
              nix.settings.experimental-features = ["nix-command" "flakes"];
              environment = {
                shellInit = ''
                  clear
                  ${pkgs.bat}/bin/bat --decorations=never --language=markdown <<EOF
                  # Welcome to your NixOS-based VM!

                    - User: $(whoami)
                  EOF
                '';
                systemPackages = devGenericTools;
              };
              services.getty.autologinUser = "root";
              system.stateVersion = "23.05";
            }
          ];
        };
        emulated-dev = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = let
            pkgs = import nixpkgs {
              inherit system;
              crossSystem.config = "aarch64-unknown-linux-gnu";
            };
          in [
            {nixpkgs.crossSystem.config = "aarch64-unknown-linux-gnu";}
            microvm.nixosModules.microvm
            {
              microvm = {
                cpu = "cortex-a72";
                vcpu = 128;
                mem = 131072;
                shares = [];
                writableStoreOverlay = "/nix/.rw-store";
                volumes = [
                  {
                    image = "nix-store-overlay.img";
                    mountPoint = "/nix/.rw-store";
                    size = 262144;
                  }
                ];
                interfaces = [
                  {
                    type = "user";
                    id = "microvm-test";
                    mac = "02:00:00:00:00:01";
                  }
                ];
                hypervisor = "qemu";
              };
              systemd.services.run-script-at-init = {
                description = "A minimal example for a custom systemd service";
                wantedBy = ["multi-user.target"];
                # serviceConfig = {
                #   ExecStart = "/some/path";
                #   User = "root";
                #   Group = "root";
                # };
                script = ''
                  touch /root/hello-world
                '';
              };
              networking.hostName = "nixity-vm";
              nix.settings.experimental-features = ["nix-command" "flakes"];
              environment = {
                shellInit = ''
                  clear
                  ${pkgs.bat}/bin/bat --decorations=never --language=markdown <<EOF
                  # Welcome to your NixOS-based VM!

                    - User: $(whoami)
                  EOF
                '';
                systemPackages = with pkgs; [git];
              };
              services.getty.autologinUser = "root";
              system.stateVersion = "23.05";
            }
          ];
        };
      };
    })
    // {
      templates = rec {
        elm = {
          path = ./devenv/templates/elm;
          description = "Elm project";
        };
        go = {
          path = ./devenv/templates/go;
          description = "Go project";
        };
        haskell = {
          path = ./devenv/templates/haskell;
          description = "Haskell project";
        };
        python = {
          path = ./devenv/templates/python;
          description = "Python project";
        };
        rust = {
          path = ./devenv/templates/rust;
          description = "Rust project";
        };
        webapp = {
          path = ./devenv/templates/webapp;
          description = "Web app project";
        };
      };
    }
    // {
      # Used by helpers such as ,,,
      inherit nixpkgs;
    };
}
