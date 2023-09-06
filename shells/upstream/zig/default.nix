{
  mkShell,
  gcc,
  zstd,
  cmake,
  libxml2,
  llvmPackages_16,
  stdenv,
}:
mkShell {
  NIX_HARDENING_ENABLE = "";
  nativeBuildInputs = [gcc zstd];
  buildInputs = [cmake libxml2] ++ (with llvmPackages_16; [libclang libllvm lld]);
  shellHook = ''
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${stdenv.cc.cc.lib}/lib"
  '';
}
