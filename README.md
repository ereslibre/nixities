# nixities

This project contains targeted Nix flakes for very specific
purposes. By exposing flake outputs, this tiny environments are
trivial to reproduce in different systems.

## Current flake outputs

- `nix develop github:ereslibre/nixities#php`

    Build PHP to `wasm32-wasi`. Clone the [PHP
    project](https://github.com/php/php-src), execute the `nix
    develop` command inside of it, and run the following:

    ```shell-session
    $ ./buildconf --force
    $ ./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi
        --target=wasm32-wasi target_alias=wasm32-musl-wasi --without-iconv
        --without-openssl --without-libxml --without-pear --disable-phar
        --disable-opcache --disable-zend-signals --without-pcre-jit
        --disable-pdo --disable-fiber-asm --disable-posix
        --without-sqlite3 --disable-dom --disable-xml --disable-simplexml
        --without-libxml --disable-xmlreader --disable-xmlwriter
    $ make -j cgi cli
    ```
