{
  description = "nixities";

  inputs = {
    dotfiles = {
      url = "github:ereslibre/dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    dotfiles,
    flake-utils,
    microvm,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      wasmRuntimes = with pkgs; [wasmer wasmtime wavm];
      wasmGenericTools = with pkgs; [binaryen wabt wasm-tools];
      devGenericTools = with pkgs; [lldb pkg-config];
      allWasmTools = wasmGenericTools ++ wasmRuntimes ++ devGenericTools;
    in {
      packages = {
        wasi-sdk-19 = pkgs.callPackage ./packages/wasi-sdk-19 {};
        wasi-sdk-20 = pkgs.callPackage ./packages/wasi-sdk-20 {};
        vms =
          nixpkgs.lib.mapAttrs
          (name: nixosDefinition: nixosDefinition.config.microvm.declaredRunner)
          self.outputs.nixosConfigurations.${system}.vms;
      };
      legacyPackages = pkgs;
      devShells = {
        clang = pkgs.callPackage ./shells/clang {inherit devGenericTools;};
        containerd-wasm-shims = pkgs.callPackage ./shells/containerd-wasm-shims {};
        default = self.devShells.${system}.nix;
        nix = pkgs.mkShell {buildInputs = with pkgs; [alejandra];};
        onnx = pkgs.callPackage ./shells/onnx {};
        rustc = pkgs.callPackage ./shells/rustc {inherit devGenericTools;};
        wasi-libc =
          pkgs.callPackage ./shells/wasi-libc {inherit allWasmTools;};
        wasi-sdk-19 = pkgs.callPackage ./shells/wasi-sdk {
          inherit allWasmTools;
          wasi-sdk = self.packages.${system}.wasi-sdk-19;
        };
        wasi-sdk-20 = pkgs.callPackage ./shells/wasi-sdk {
          inherit allWasmTools;
          wasi-sdk = self.packages.${system}.wasi-sdk-20;
        };
        wasi-vfs-19 = pkgs.callPackage ./shells/wasi-vfs {
          inherit allWasmTools;
          wasi-sdk = self.packages.${system}.wasi-sdk-19;
        };
        wasi-vfs-20 = pkgs.callPackage ./shells/wasi-vfs {
          inherit allWasmTools;
          wasi-sdk = self.packages.${system}.wasi-sdk-20;
        };
        wasm = pkgs.callPackage ./shells/wasm {inherit allWasmTools;};
        work = {
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
              networking.hostName = "nixity-vm";
              nix.settings.experimental-features = ["nix-command" "flakes"];
              environment.systemPackages = devGenericTools;
              services.getty.autologinUser = "root";
              system.stateVersion = "23.05";
            }
          ];
        };
      };
    })
    // {
      templates = rec {
        nixity = {
          path = ./devenv/templates/nixity;
          description = "A flake using the nixities project for devenv";
        };
        default = nixity;
      };
    }
    // {inherit nixpkgs;};
}
