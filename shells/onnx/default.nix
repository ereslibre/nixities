{
  mkShell,
  clang,
  cmake,
  cudaPackages,
  libclang,
  pkg-config,
  protobuf,
  python3,
}:
mkShell {
  PROTOC = "${protobuf}/bin/protoc";
  buildInputs = [clang cmake cudaPackages.cuda_nvcc libclang pkg-config python3];
}
