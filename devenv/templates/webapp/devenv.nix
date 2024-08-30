{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
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

  packages = with pkgs; [alejandra just];

  processes = {
    backend.exec = "cd backend && db-setup && cargo run";
  };
}
