{
  mkShell,
  allWasmTools,
  wasi-sdk,
  pkgs,
}:
mkShell {
  buildInputs = [pkgs.llvmPackages_latest.clang];
  nativeBuildInputs = allWasmTools;
  shellHook = ''
    export WASI_SDK_PATH=${wasi-sdk}
    export CC="${wasi-sdk}/bin/clang --sysroot=${wasi-sdk}/share/wasi-sysroot"
  '';
}
