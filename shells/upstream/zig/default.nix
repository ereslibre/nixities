{
  mkShell,
  cmake,
  libxml2,
  llvmPackages_16,
  stdenv,
}:
mkShell.override {inherit (llvmPackages_16) stdenv;} {
  buildInputs = [cmake libxml2] ++ (with llvmPackages_16; [libclang libllvm lld]);
  shellHook = ''
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${stdenv.cc.cc.lib}/lib"
  '';
}
