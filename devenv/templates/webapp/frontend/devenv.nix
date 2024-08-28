{ pkgs, ... }: {
  env = {
    # `elm-land server` uses this envvar for setting up
    # its listener
    HOST = "0.0.0.0";
  };

  languages.elm.enable = true;

  packages =
    (with pkgs.elmPackages;
      [
        elm-land
        elm-review
        elm-test
      ]) ++
    (with pkgs;
      [
        tailwindcss
        tailwindcss-language-server
      ]);

  pre-commit.hooks = {
    elm-format.enable = true;
    elm-review.enable = false;
    elm-test.enable = false;
  };

  processes = {
    frontend.exec = "cd frontend && ${pkgs.elmPackages.elm-land}/bin/elm-land server";
    tailwindcss-watcher.exec = "${pkgs.tailwindcss}/bin/tailwindcss -i frontend/tailwind.css -o frontend/static/style.css --watch=always";
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
}
