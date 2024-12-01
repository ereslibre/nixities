{
  pkgs,
  pkgs-elm,
}: {
  env = {
    # `elm-land server` uses this envvar for setting up
    # its listener
    HOST = "0.0.0.0";
  };

  packages =
    (with pkgs-elm.elmPackages; [
      elm
      elm-format
      elm-land
      elm-language-server
      elm-review
      elm-test
    ])
    ++ (with pkgs; [
      tailwindcss
      tailwindcss-language-server
    ]);

  pre-commit.hooks = {
    elm-format.enable = true;
    elm-review.enable = false;
    elm-test.enable = false;
  };

  processes = {
    frontend.exec = "cd frontend && ${pkgs-elm.elmPackages.elm-land}/bin/elm-land server";
    tailwindcss-watcher.exec = "cd frontend && ${pkgs.tailwindcss}/bin/tailwindcss -c tailwind.config.js -i tailwind.css -o static/style.css --watch=always";
  };

  scripts = {
    # User scripts
    elm-init.exec = ''
      mkdir -p .app
      ${pkgs-elm.elmPackages.elm-land}/bin/elm-land init .app
      cat .app/.gitignore >> .gitignore
      rm .app/.gitignore
      mv -n .app/{.*,*} .
      rm -f .app/elm-land.json
      rm -rf .app
      mkdir static
      touch tailwind.css static/style.css
    '';
  };
}
