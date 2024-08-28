{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  packages = with pkgs; [alejandra just];

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
}
