{
  mkShell,
  gcc,
  ninja,
  zstd,
  cmake,
  libxml2,
  llvmPackages_16,
  bat,
  stdenv,
}:
mkShell {
  NIX_HARDENING_ENABLE = "";
  nativeBuildInputs = [gcc ninja zstd];
  buildInputs = [cmake libxml2] ++ (with llvmPackages_16; [libclang libllvm lld]);
  shellHook = ''
    ${bat}/bin/bat --language=markdown --decorations=never <<"EOF"
    # Building Zig

    First, build the stage3 compiler. Recommended way:
      - `mkdir build`
      - `cmake -DCMAKE_BUILD_TYPE=Release -GNinja -DZIG_NO_LIB=ON`
      - `ninja`

    This `ninja` step also applies if there were upstream changes.

    # Development cycle

    Make your changes to the compiler.

    Build the stage4 compiler with your changes:
      - `stage3/bin/zig build -p stage4 -Denable-llvm -Dno-lib`
    EOF

    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${stdenv.cc.cc.lib}/lib"
  '';
}
