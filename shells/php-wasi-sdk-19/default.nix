{ mkShell, allWasmTools, autoconf, bison, coreutils, php, re2c, wasi-sdk-19 }:
mkShell {
  buildInputs = allWasmTools ++ [ autoconf bison coreutils php re2c ];
  shellHook = ''
    export WASI_SDK_PATH="${wasi-sdk-19}"
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
       ./buildconf --force; ./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi --without-iconv --without-openssl --without-libxml --without-pear --disable-phar --disable-opcache --disable-zend-signals --without-pcre-jit --disable-pdo --disable-fiber-asm --disable-posix --without-sqlite3 --disable-dom --disable-xml --disable-simplexml --without-libxml --disable-xmlreader --disable-xmlwriter --disable-fileinfo --disable-session
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
}
