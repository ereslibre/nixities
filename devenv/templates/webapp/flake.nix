{
  inputs = {
    mkElmDerivation = {
      url = "github:jeslie0/mkElmDerivation";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    mkElmDerivation,
    nixpkgs,
    devenv,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
    project = {
      name = "webapp";
      version = "0.1";
      revision =
        if (self ? rev)
        then self.rev
        else
          (
            if (self ? dirtyRev)
            then self.dirtyRev
            else "local-filesystem"
          );
    };
  in {
    containers = forEachSystem (system: let
      pkgs = import nixpkgs {
        overlays = [mkElmDerivation.overlays.mkElmDerivation];
        inherit system;
      };
      databaseURL = "sqlite:///app/db/core.sqlite3";
    in {
      backend = {
        autoStart = true;
        config = {
          config,
          pkgs,
          lib,
          ...
        }: {
          networking.firewall = {
            enable = true;
            allowedTCPPorts = [80 443];
          };

          systemd.services.webapp = {
            enable = true;
            wantedBy = ["default.target"];
            environment = {
              DATABASE_URL = databaseURL;
            };
            path = with pkgs; [openssl.dev sqlite];
            preStart = ''
              mkdir -p /app/db
              ${pkgs.sqlx-cli}/bin/sqlx database setup --source=${./backend/migrations}
            '';
            serviceConfig = {
              Type = "exec";
              ExecStart = "${self.packages.${system}.backend}/bin/backend";
            };
          };

          system.stateVersion = "24.05";

          users = {
            mutableUsers = false;
            users.root.initialPassword = "";
          };
        };
      };
    });

    packages = forEachSystem (system: let
      pkgs = import nixpkgs {
        overlays = [mkElmDerivation.overlays.mkElmDerivation];
        inherit system;
      };
    in {
      backend = pkgs.rustPlatform.buildRustPackage {
        name = "${project.name}-backend";
        cargoLock.lockFile = ./backend/Cargo.lock;
        src = ./backend;
        env = {
          GIT_REVISION = project.revision;
        };
      };
      frontend = pkgs.mkElmDerivation {
        name = "${project.name}-frontend";
        src = ./frontend;
        env = {
          GIT_REVISION = project.revision;
        };
        buildPhase = ''
          ${pkgs.elmPackages.elm-land}/bin/elm-land build
        '';
        installPhase = ''
          mkdir -p $out
          cp -rv dist/* $out/
        '';
      };
      web = pkgs.stdenv.mkDerivation {
        name = "${project.name}-web";
        src = ./web;
        env = {
          GIT_REVISION = project.revision;
        };
        outputs = ["out"];
        dontBuild = true;
        installPhase = ''
          mkdir -p $out
          cp -rv . $out/
        '';
      };
      default = pkgs.stdenv.mkDerivation {
        inherit (project) name;
        dontUnpack = true;
        dontBuild = true;
        outputs = ["backend" "frontend" "out" "web"];
        installPhase = ''
          # Backend
          mkdir -p $backend
          cp -rv ${self.packages.${system}.backend}/* $backend

          # Frontend
          mkdir -p $frontend
          cp -rv ${self.packages.${system}.frontend}/* $frontend

          # Web
          cp -rv ${self.packages.${system}.web} $web/

          # All
          mkdir -p $out/{backend,frontend,web}
          cp -rv $backend/* $out/backend/
          cp -rv $frontend/* $out/frontend/
          cp -rv $web/* $out/web/
        '';
      };
      devenv-up = self.devShells.${system}.default.config.procfileScript;
    });

    devShells =
      forEachSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;

          modules = [
            {
              imports = [./backend ./frontend];

              env.GIT_REVISION = "devenv";

              enterShell = ''
                cat <<'EOF' | ${pkgs.bat}/bin/bat --language=markdown
                  # Welcome to a new webapp!

                  ## Init

                  Inspect the backend, and create a frontend --if applies.--

                  In order to create a frontend, run:
                  - `pushd frontend && elm-init && popd`

                  Now, you can start the devenv environment: `devenv up`.
                EOF
              '';

              packages = with pkgs; [alejandra findutils just];

              pre-commit.hooks.alejandra.enable = true;
            }
          ];
        };
      });
  };
}
