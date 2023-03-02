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
        devShells.php = pkgs.mkShell {
          buildInputs = with pkgs; [
            autoconf bison php re2c
          ];
          shellHook = ''
            export WASI_SDK_PATH=/home/ereslibre/wasi-sdk-19.0
            export CC="$WASI_SDK_PATH/bin/clang --sysroot=$WASI_SDK_PATH/share/wasi-sysroot"
            export CFLAGS="-D_WASI_EMULATED_GETPID -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS"
            export LDFLAGS="-lwasi-emulated-getpid -lwasi-emulated-signal -lwasi-emulated-process-clocks"
          '';
        };
      }
    );
}
