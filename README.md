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
    $ configure
    $ build
    $ runtests
    ```
