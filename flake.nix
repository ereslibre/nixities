{
  description = "nixities";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
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

            sourceRoot = "${pname}-${version}.0";
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

            meta = {
              platforms = [ "x86_64-linux" ];
            };
          };
        };
        devShells = {
          php = pkgs.mkShell {
            buildInputs = with pkgs; [
              autoconf binaryen bison coreutils php re2c wabt wasmtime
            ];
            shellHook = ''
              export WASI_SDK_PATH="${self.packages.${system}.wasi-sdk}"
              export PATH=$PATH:$WASI_SDK_PATH/bin
              export CC="$WASI_SDK_PATH/bin/clang --sysroot=$WASI_SDK_PATH/share/wasi-sysroot"
              export CFLAGS="-O2 -D_WASI_EMULATED_GETPID -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS"
              export LDFLAGS="-lwasi-emulated-getpid -lwasi-emulated-signal -lwasi-emulated-process-clocks"
              export SKIP_IO_CAPTURE_TESTS=1
              export TEST_PHP_JUNIT=junit.out.xml
              export STACK_LIMIT_DEFAULTS_CHECK=1
              export TEST_PHP_EXECUTABLE=/tmp/wasmtime-run-cli.sh
              export TEST_PHP_CGI_EXECUTABLE=/tmp/wasmtime-run-cgi.sh
              export TEST_PHPDBG_EXECUTABLE=""

              cat <<-'EOF' > /tmp/wasmtime-run-cli.sh
              	#!/usr/bin/env bash
              	WASMTIME_BACKTRACE_DETAILS=1 wasmtime run --allow-unknown-exports --mapdir /::/ sapi/cli/php -- "$@"
              EOF
              chmod +x /tmp/wasmtime-run-cli.sh
              cat <<-'EOF' > /tmp/wasmtime-run-cgi.sh
              	#!/usr/bin/env bash
              	WASMTIME_BACKTRACE_DETAILS=1 wasmtime run --allow-unknown-exports --mapdir /::/ sapi/cgi/php-cgi -- "$@"
              EOF
              chmod +x /tmp/wasmtime-run-cgi.sh

              configure() {
                 ./buildconf --force; ./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi --without-iconv --without-openssl --without-libxml --without-pear --disable-phar --disable-opcache --disable-zend-signals --without-pcre-jit --disable-pdo --disable-fiber-asm --disable-posix --without-sqlite3 --disable-dom --disable-xml --disable-simplexml --without-libxml --disable-xmlreader --disable-xmlwriter
              }

              build() {
                make -j cgi cli
              }

              optimize() {
                wasm-opt -O sapi/cli/php -o sapi/cli/php.optimized
                wasm-opt -O sapi/cgi/php-cgi -o sapi/cgi/php-cgi.optimized
              }

              runtests() {
                php run-tests.php -q \
                     -j$(nproc) \
                     -g FAIL,BORK,LEAK,XLEAK \
                     --no-progress \
                     --offline \
                     --show-diff \
                     --show-slow 1000 \
                     --set-timeout 120 2>&1 | tee test-results.txt
              }
          '';
          };
        };
      }
    );
}
