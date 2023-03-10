{
  description = "nixities";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
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
        packages = { wasi-sdk = pkgs.callPackage ./packages/wasi-sdk { }; };
        devShells = {
          nix = pkgs.mkShell { buildInputs = with pkgs; [ nixfmt ]; };
          php = pkgs.callPackage ./shells/php {
            inherit allWasmTools;
            inherit (self.packages.${system}) wasi-sdk;
          };
          wasi-libc =
            pkgs.mkShell.override { inherit (pkgs.pkgsLLVM) stdenv; } {
              buildInputs = [ allWasmTools ];
              shellHook = let llvm = pkgs.llvmPackages_latest.llvm;
              in ''
                export AR=${llvm}/bin/llvm-ar
                export NM=${llvm}/bin/llvm-nm
              '';
            };
        };
      });
}
