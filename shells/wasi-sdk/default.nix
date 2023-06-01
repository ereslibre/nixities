{
  mkShell,
  allWasmTools,
  wasi-sdk,
}:
mkShell {
  buildInputs = allWasmTools;
  shellHook = ''
    export PATH=$PATH:${wasi-sdk}/bin
    export WASI_SDK_PATH="${wasi-sdk}"
    export CC="${wasi-sdk}/bin/clang --sysroot=${wasi-sdk}/share/wasi-sysroot"
  '';
}
