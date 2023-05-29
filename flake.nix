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
          wasi-sdk-19 = pkgs.callPackage ./packages/wasi-sdk-19 { };
          wasi-sdk-20 = pkgs.callPackage ./packages/wasi-sdk-20 { };
        };
        legacyPackages = pkgs;
        devShells = let
          wasmRuntimes = with pkgs; [ wasmer wasmtime wavm ];
          wasmGenericTools = with pkgs; [ binaryen wabt wasm-tools ];
          devGenericTools = with pkgs; [ lldb ];
          allWasmTools = wasmGenericTools ++ wasmRuntimes ++ devGenericTools;
        in {
          clang = pkgs.callPackage ./shells/clang { inherit devGenericTools; };
          default = self.devShells.${system}.nix;
          nix = pkgs.mkShell { buildInputs = with pkgs; [ nixfmt ]; };
          php.wasi-sdk-19 = pkgs.callPackage ./shells/php-wasi-sdk-19 {
            inherit allWasmTools;
            inherit (self.packages.${system}) wasi-sdk-19;
          };
          php.wasi-sdk-20 = pkgs.callPackage ./shells/php-wasi-sdk-20 {
            inherit allWasmTools;
            inherit (self.packages.${system}) wasi-sdk-20;
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
          work = {
            wws = pkgs.callPackage ./shells/work/wws {
              inherit (pkgs) pkg-config clang openssl;
            };
          };
        };
      }) // {
        inherit nixpkgs;
        templates = rec {
          nixity = {
            path = ./devenv/templates/nixity;
            description = "A flake using the nixities project for devenv";
          };
          default = nixity;
        };
      };
}
