.PHONY: fmt
fmt:
	find . -name "*.nix" | xargs nix develop --command nixfmt

.PHONY: lint
lint:
	nix develop --command nix-linter -r
