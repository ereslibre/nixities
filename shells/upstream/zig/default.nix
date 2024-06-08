{
  mkShell,
  ninja,
  cmake,
  llvmPackages_16,
  binaryen,
  libxml2,
  wasmtime,
  zlib,
  bat,
}:
mkShell {
  NIX_HARDENING_ENABLE = "";
  nativeBuildInputs = [ninja cmake llvmPackages_16.llvm.dev];
  buildInputs = [binaryen libxml2 wasmtime zlib] ++ (with llvmPackages_16; [libclang lld llvm]);
  shellHook = ''
    ${bat}/bin/bat --language=markdown --decorations=never <<"EOF"
    # Building Zig

    First, build the stage3 compiler. Recommended way:
      - `mkdir build; cd build`
      - `cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_SKIP_BUILD_RPATH=ON -DZIG_STATIC_LLVM=ON -DZIG_TARGET_MCPU=baseline -GNinja -DZIG_NO_LIB=ON ..`
      - `ninja`

    This `ninja` step also applies if there were upstream changes.

    # Development cycle

    Make your changes to the compiler.

    Build the stage4 compiler with your changes:
      - `stage3/bin/zig build -p stage4 -Denable-llvm -Dno-lib`
    EOF
  '';
}
