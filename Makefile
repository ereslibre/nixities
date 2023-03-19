.PHONY: fmt
fmt:
	find . -name "*.nix" | xargs nix develop --command nixfmt
