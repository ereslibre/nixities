{
  mkShell,
  pkgs,
  devGenericTools,
}:
mkShell {
  buildInputs = with pkgs; [clang pkg-config udev.dev fontconfig.dev xorg.libX11.dev libunwind.dev python312 python312Packages.packaging] ++ devGenericTools;

  shellHook = ''
    export LIBCLANG_PATH="${pkgs.libclang.lib}/lib"
  '';
}
