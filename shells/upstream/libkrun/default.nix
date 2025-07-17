{
  mkShell,
  pkgs,
}:
mkShell {
  buildInputs = [pkgs.pkgsStatic.stdenv pkgs.glibc pkgs.glibc.static];
}
