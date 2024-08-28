{ pkgs, ... }: let
  databasePath  = "db/core.sqlite3";
in {
  env = {
    DATABASE_URL = "sqlite:${databasePath}";
  };

  enterShell = ''
    mkdir -p backend/db
  '';

  packages = with pkgs;
    [
      openssl.dev
      sqlite
      sqlx-cli
    ];

  processes = {
    backend.exec = "cd backend && sqlx database create --database-url=sqlite:${databasePath} && sqlx migrate run --database-url=sqlite:${databasePath} --source=migrations && cargo run";
  };

  services.postgres.enable = true;
}
