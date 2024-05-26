fmt:
	find . -name "*.nix" | xargs nix develop --command alejandra

generic-dev:
    nix run .#vms.generic-dev

emulated-dev:
    nix run .#vms.emulated-dev
