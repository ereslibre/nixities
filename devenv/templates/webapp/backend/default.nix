{pkgs, ...}: let
  databasePath = "db/core.sqlite3";
in {
  env = {
    DATABASE_URL = "sqlite:${databasePath}";
  };

  languages.rust.enable = true;

  packages = with pkgs; [
    openssl.dev
    sqlite
    sqlx-cli
  ];

  pre-commit.hooks.rustfmt.enable = true;

  processes = {
    backend.exec = "cd backend && db-setup && cargo run";
  };

  scripts = {
    db-setup.exec = "sqlx database setup --database-url=sqlite:${databasePath} --source=migrations";
    db-migrate.exec = "sqlx migrate run --database-url=sqlite:${databasePath} --source=migrations";
  };
}
