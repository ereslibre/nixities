{
  mkShell,
  clang,
  cmake,
  cudaPackages,
  libclang,
  pkg-config,
  python3,
}:
mkShell {buildInputs = [clang cmake cudaPackages.cuda_nvcc libclang pkg-config python3];}
