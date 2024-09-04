{pkgs, ...}: let
  databasePath = "db/core.sqlite3";
in {
  env = {
    DATABASE_URL = "sqlite:${databasePath}";
  };

  packages = with pkgs; [
    openssl.dev
    sqlite
    sqlx-cli
  ];

  scripts = {
    db-setup.exec = "sqlx database setup --database-url=sqlite:${databasePath} --source=migrations";
    db-migrate.exec = "sqlx migrate run --database-url=sqlite:${databasePath} --source=migrations";
  };
}
