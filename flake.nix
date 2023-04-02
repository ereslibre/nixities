{
  description = "nixities";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        wasmRuntimes = with pkgs; [ wasmtime ];
        wasmGenericTools = with pkgs; [ binaryen wabt ];
        devGenericTools = with pkgs; [ lldb ];
        allWasmTools = wasmGenericTools ++ wasmRuntimes ++ devGenericTools;
      in {
        packages = {
          wasi-sdk = pkgs.callPackage ./packages/wasi-sdk { };
        } // {
          # Re-export the whole legacyPackages expression for this
          # system. This enables for cached ephemeral environments
          # thanks to the `nixities` flake lock
          nixpkgs = pkgs;
        };
        devShells = {
          default = pkgs.mkShell { buildInputs = with pkgs; [ nixfmt ]; };
          clang = pkgs.mkShell {
            buildInputs = (with pkgs; [ autoconf automake clang cmake ])
              ++ devGenericTools;
          };
          nix = pkgs.mkShell { buildInputs = with pkgs; [ nixfmt ]; };
          php = pkgs.callPackage ./shells/php {
            inherit allWasmTools;
            inherit (self.packages.${system}) wasi-sdk;
          };
          wasi-libc =
            pkgs.mkShell.override { inherit (pkgs.pkgsLLVM) stdenv; } {
              nativeBuildInputs = allWasmTools;
              shellHook = let llvm = pkgs.llvmPackages_latest.llvm;
              in ''
                export AR=${llvm}/bin/llvm-ar
                export NM=${llvm}/bin/llvm-nm
              '';
            };
          wasi-vfs = pkgs.mkShell
            (let wasi-sdk = self.packages.${system}.wasi-sdk;
             in {
               buildInputs = with pkgs; [ llvmPackages_latest.clang ];
              nativeBuildInputs = allWasmTools;
              shellHook = ''
                export WASI_SDK_PATH=${wasi-sdk}
                export CC="${wasi-sdk}/bin/clang --sysroot=${wasi-sdk}/share/wasi-sysroot"
              '';
            });
          wasm =
            pkgs.mkShell { buildInputs = allWasmTools ++ devGenericTools; };
        };
      });
}
