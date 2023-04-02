{ mkShell, allWasmTools, devGenericTools }:
mkShell { buildInputs = allWasmTools ++ devGenericTools; }
