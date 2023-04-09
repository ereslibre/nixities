{ pkgs, nixities, ... }:

let inherit (pkgs.stdenv) system;
in {
  packages = with nixities.packages.${system}.nixpkgs;
    [ cowsay ] ++ (with nixities.packages.${system}; [ wasi-sdk ]);

  enterShell = ''
    cowsay 'Welcome!'
  '';
}
