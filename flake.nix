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
          temporary.wasmio = {
            spin = pkgs.callPackage ./packages/spin { };
            wws = pkgs.callPackage ./packages/wws { };
          };
          wasi-sdk = pkgs.callPackage ./packages/wasi-sdk { };
        } // {
          # Re-export the whole legacyPackages expression for this
          # system. This enables for cached ephemeral environments
          # thanks to the `nixities` flake lock
          nixpkgs = pkgs;
        };
        devShells = {
          temporary.wasmio = {
            wws = pkgs.mkShell { buildInputs = with pkgs; [ go nodejs ]; };
            wlr = pkgs.mkShell rec {
              PKG_CONFIG_SYSROOT_DIR =
                "/home/ereslibre/wasmio-demo/wlr-demo/libs/libbundle_wlr-0.1.0-wasi-sdk-19.0";
              PKG_CONFIG_PATH =
                "${PKG_CONFIG_SYSROOT_DIR}/lib/wasm32-wasi/pkgconfig/";
              nativeBuildInputs = with pkgs; [
                pkg-config
                self.packages.${system}.wasi-sdk
              ];
              buildInputs = with pkgs;
                [ allWasmTools go pkg-config wasmtime ]
                ++ (with self.packages.${system}.temporary.wasmio; [
                  spin
                  wws
                ]);
            };
          };
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
          wasm =
            pkgs.mkShell { buildInputs = allWasmTools ++ devGenericTools; };
        };
      });
}
