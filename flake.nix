{
  description = "nixities";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages = {
          wasi-sdk = let
            pname = "wasi-sdk";
            version = "19";
          in pkgs.stdenv.mkDerivation {
            inherit pname version;

            sourceRoot = "wasi-sdk-${version}.0";
            dontBuild = true;
            dontConfigure = true;
            dontStrip = true;

            nativeBuildInputs = with pkgs; [
              autoPatchelfHook
            ];

            installPhase = ''
              mkdir -p $out/{bin,lib,share}
              mv bin/* $out/bin/
              mv lib/* $out/lib/
              mv share/* $out/share/
            '';

            src = pkgs.fetchurl {
              url = "https://github.com/WebAssembly/${pname}/releases/download/${pname}-${version}/${pname}-${version}.0-linux.tar.gz";
              hash = "sha256-2QCryCbuwZVbmv0lDnzCSWM4q79sRA2GoxPAbkIIP6E=";
            };
          };
        };
        devShells = {
          php = pkgs.mkShell {
            buildInputs = with pkgs; [
              autoconf bison php re2c
            ];
            shellHook = ''
              export WASI_SDK_PATH="${self.packages.${system}.wasi-sdk}"
              export PATH=$PATH:$WASI_SDK_PATH/bin
              export CC="$WASI_SDK_PATH/bin/clang --sysroot=$WASI_SDK_PATH/share/wasi-sysroot"
              export CFLAGS="-D_WASI_EMULATED_GETPID -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS"
              export LDFLAGS="-lwasi-emulated-getpid -lwasi-emulated-signal -lwasi-emulated-process-clocks"
          '';
          };
        };
      }
    );
}
