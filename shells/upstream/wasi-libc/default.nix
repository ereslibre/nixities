{
  mkShell,
  pkgsLLVM,
  allWasmTools,
  llvmPackages_16,
}: let
  llvmPackages = llvmPackages_16;
in
  mkShell.override {inherit (llvmPackages) stdenv;} {
    nativeBuildInputs = allWasmTools;
    shellHook = ''
      export AR=${llvmPackages.llvm}/bin/llvm-ar
      export NM=${llvmPackages.llvm}/bin/llvm-nm
    '';
  }
