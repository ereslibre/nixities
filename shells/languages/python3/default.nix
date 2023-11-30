{
  mkShell,
  poetry,
  python3Packages,
}:
mkShell {buildInputs = [poetry] ++ (with python3Packages; [pip]);}
