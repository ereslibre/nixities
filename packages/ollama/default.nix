{
  llama-cpp,
  ollama,
}:
ollama.override {
  llama-cpp = llama-cpp.override {
    cudaSupport = true;
  };
}
