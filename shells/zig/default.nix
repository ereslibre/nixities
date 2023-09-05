{
  mkShell,
  cmake,
  libxml2,
  llvmPackages_16,
}:
mkShell.override {inherit (llvmPackages_16) stdenv;} {
  buildInputs = [cmake libxml2] ++ (with llvmPackages_16; [libclang libllvm lld]);
}
