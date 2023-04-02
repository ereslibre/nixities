{ mkShell, pkgsLLVM, allWasmTools, llvmPackages_latest }:
mkShell.override { inherit (pkgsLLVM) stdenv; } {
  nativeBuildInputs = allWasmTools;
  shellHook = let llvm = llvmPackages_latest.llvm;
  in ''
    export AR=${llvm}/bin/llvm-ar
    export NM=${llvm}/bin/llvm-nm
  '';
}
