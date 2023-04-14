{
  description = "nixities";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = {
          wasi-sdk = pkgs.callPackage ./packages/wasi-sdk { };
        } // {
          # Re-export the whole legacyPackages expression for this
          # system. This enables for cached ephemeral environments
          # thanks to the `nixities` flake lock
          nixpkgs = pkgs;
        };
        devShells = let
          wasmRuntimes = with pkgs; [ wasmtime ];
          wasmGenericTools = with pkgs; [ binaryen wabt wasm-tools ];
          devGenericTools = with pkgs; [ lldb ];
          allWasmTools = wasmGenericTools ++ wasmRuntimes ++ devGenericTools;
        in {
          clang = pkgs.callPackage ./shells/clang { inherit devGenericTools; };
          default = self.devShells.${system}.nix;
          nix = pkgs.mkShell { buildInputs = with pkgs; [ nixfmt ]; };
          php.wasi = pkgs.callPackage ./shells/php-wasi {
            inherit allWasmTools;
            inherit (self.packages.${system}) wasi-sdk;
          };
          wasi-libc =
            pkgs.callPackage ./shells/wasi-libc { inherit allWasmTools; };
          wasi-sdk = pkgs.callPackage ./shells/wasi-sdk {
            inherit allWasmTools;
            inherit (self.packages.${system}) wasi-sdk;
          };
          wasi-vfs = pkgs.callPackage ./shells/wasi-vfs {
            inherit allWasmTools;
            inherit (self.packages.${system}) wasi-sdk;
          };
          wasm = pkgs.callPackage ./shells/wasm { inherit allWasmTools; };
        };
      }) // {
        templates = rec {
          nixity = {
            path = ./devenv/templates/nixity;
            description = "A flake using the nixities project for devenv";
            welcomeText = ''
              # Update inputs
              ```sh
                devenv update
              ```
            '';
          };
          default = nixity;
        };
      };
}
