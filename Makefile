.PHONY: fmt
fmt:
	find . -name "*.nix" | xargs nix develop .#nix --command nixfmt
