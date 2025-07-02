{pkgs, ...}: let
  databaseURL = "sqlite://db/core.sqlite3";
in {
  env = {
    DATABASE_URL = databaseURL;
  };

  languages.rust.enable = true;

  packages = with pkgs; [
    openssl.dev
    sqlite
    sqlx-cli
  ];

  pre-commit = {
    hooks.rustfmt.enable = true;
    settings.rust.cargoManifestPath = "./backend/Cargo.toml";
  };

  processes = {
    backend.exec = "cd backend && just db-setup && cargo run --bin backend";
  };

  scripts = {
    db-setup.exec = "sqlx database setup --source=migrations";
    db-migrate.exec = "sqlx migrate run --source=migrations";
  };
}
