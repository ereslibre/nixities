{ nixities }:

{
  packages = with nixities.legacyPackages.${pkgs.stdenv.system};
    [ cowsay ] ++ (with nixities.packages.${pkgs.stdenv.system}; [ wasi-sdk ]);

  enterShell = ''
    cowsay 'Welcome!'
  '';
}
