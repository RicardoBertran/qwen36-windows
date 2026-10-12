# Descargas fijadas y verificación

## llama.cpp oficial b11559 · Windows x64 · CUDA 13.4

[Release y archivos originales](https://github.com/ggml-org/llama.cpp/releases/tag/b11559).

| Archivo | SHA256 |
|---|---|
| llama-b11559-bin-win-cuda-13.4-x64.zip | `419de1292bcb772824fec45e4bc3722e79459e8d89c552578bafdad51266294a` |
| cudart-llama-bin-win-cuda-13.4-x64.zip | `738f8c251ac22b70c3ae6f83a10cf222725df0395246a2cf58f32bdb85fbe668` |

En PowerShell puedes comparar un archivo manualmente:

```powershell
Get-FileHash -LiteralPath 'INDICA_AQUI_TU_RUTA\archivo.zip' -Algorithm SHA256
```

## GGUF para texto

- Repositorio: [ggml-org/Qwen3.6-35B-A3B-GGUF](https://huggingface.co/ggml-org/Qwen3.6-35B-A3B-GGUF/tree/baec3ebee244827cda0f4557eafa8b28f7545fa6).
- Revisión: `baec3ebee244827cda0f4557eafa8b28f7545fa6`.
- Archivo: `Qwen3.6-35B-A3B-Q4_K_M.gguf`.
- Tamaño: `20419565568` bytes, 19,02 GiB redondeados.
- SHA256: `671e47e0ec53c665d048b98c3ecbfd5236b5ca9c3e02ed19fc8f81f7b85140c7`.

El script verifica el hash tanto al descargar como si el archivo ya existe. La comprobación puede tardar porque lee el archivo completo. El script de inicio comprueba tamaño y cabecera GGUF; para repetir la verificación completa usa `Download-Model.ps1`.

Consulta las licencias y condiciones de llama.cpp, las bibliotecas NVIDIA y el modelo en sus fuentes originales. Este repositorio contiene la guía y los scripts; no redistribuye los binarios ni los pesos.
