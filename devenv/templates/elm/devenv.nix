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

  scripts =
    {
      # User scripts
      init.exec = ''
        mkdir .app
        ${pkgs.elmPackages.elm-land}/bin/elm-land init .app
        cat .app/.gitignore >> .gitignore
        rm .app/.gitignore
        mv .app/{.*,*} .
        rmdir .app
      '';
      start.exec = ''
        parallel ::: elm-land-server tailwindcss-watcher
      '';
    }
    // {
      # Auxiliary scripts
      elm-land-server.exec = ''
        elm-land server
      '';
      tailwindcss-watcher.exec = ''
        tailwindcss -i ./tailwind.css -o ./static/style.css --watch=always
      '';
    };
}
