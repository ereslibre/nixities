{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  env = {
    # `elm-land server` uses this envvar for setting up
    # its listener
    HOST = "0.0.0.0";
  };

  languages.elm.enable = true;

  packages =
    # We require these binaries to interact with their CLI
    (with pkgs.elmPackages; [elm-land elm-review elm-test])
    ++ (with pkgs; [alejandra just tailwindcss tailwindcss-language-server parallel]);

  pre-commit.hooks = {
    elm-format.enable = true;
    elm-review.enable = false;
    elm-test.enable = false;
  };

  scripts = {
    # User scripts
    elm-init.exec = ''
      mkdir .app
      ${pkgs.elmPackages.elm-land}/bin/elm-land init .app
      cat .app/.gitignore >> .gitignore
      rm .app/.gitignore
      mv .app/{.*,*} .
      rmdir .app
      mkdir static
      touch tailwind.css static/style.css
    '';
  };

  enterShell = ''
    cat <<'EOF' | ${pkgs.bat}/bin/bat --language=markdown
      # Welcome to a new webapp!

      ## Init

      Create a backend, and a frontend --if applies.--

      In order to create a backend, run:
      - `pushd backend && cargo init && popd`

      In order to create a frontend, run:
      - `pushd frontend && elm-init && popd`

      Now, you can start the devenv environment: `devenv up`.
    EOF
  '';

  processes = {
    elm-start.exec = "cd frontend && elm-land server";
    tailwindcss-watcher.exec = "tailwindcss -i ./frontend/tailwind.css -o ./frontend/static/style.css --watch=always";
  };

  services.postgres.enable = true;
}
