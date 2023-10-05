{
  lib,
  mkShell,
  wasm-tools,
  clang,
  openssl,
  openvino,
  pkg-config,
  python3,
  stdenv,
  darwin,
  iconv,
  writeText,
}:
mkShell {
  buildInputs = [wasm-tools];

  nativeBuildInputs =
    [clang pkg-config openssl]
    ++ lib.optionals stdenv.isLinux [python3]
    ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [Security SystemConfiguration] ++ [iconv]);

  shellHook = let
    openvino_plugins_xml = writeText "plugins.xml" ''
      <ie>
          <plugins>
              <plugin name="AUTO" location="libopenvino_auto_plugin.so">
              </plugin>
              <plugin name="BATCH" location="libopenvino_auto_batch_plugin.so">
              </plugin>
              <plugin name="CPU" location="libopenvino_intel_cpu_plugin.so">
              </plugin>
              <plugin name="GNA" location="libopenvino_intel_gna_plugin.so">
              </plugin>
              <plugin name="GPU" location="libopenvino_intel_gpu_plugin.so">
              </plugin>
              <plugin name="HETERO" location="libopenvino_hetero_plugin.so">
              </plugin>
              <plugin name="MULTI" location="libopenvino_auto_plugin.so">
              </plugin>
              <plugin name="MYRIAD" location="libopenvino_intel_myriad_plugin.so">
              </plugin>
          </plugins>
      </ie>
    '';
  in
    lib.optionalString stdenv.isLinux ''
      export OPENVINO_PLUGINS_XML=${openvino_plugins_xml}
      . ${openvino}/setupvars.sh
    '';
}
