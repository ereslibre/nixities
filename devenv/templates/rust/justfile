default: fmt lint build test

fmt:
  find . -name "*.nix" | xargs alejandra
  cargo fmt

lint:
  cargo clippy

build:
  cargo build

test:
  cargo test