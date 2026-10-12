# Qwen3.6-35B-A3B en Windows con NVIDIA

Guía para descargar llama.cpp oficial, instalar sus dependencias CUDA y conversar con Qwen3.6-35B-A3B desde el navegador de tu ordenador.

## 1. Antes de empezar

Necesitas Windows x64, PowerShell 5.1 o posterior, conexión a Internet, una GPU NVIDIA compatible con CUDA 13 y espacio para el modelo, las descargas y los archivos descomprimidos. El modelo ocupa **19,02 GiB**; deja espacio adicional para Windows y sus archivos temporales. No descargues las versiones ARM64, CPU o Vulkan para seguir esta guía.

Instala un controlador NVIDIA reciente desde [NVIDIA](https://www.nvidia.com/drivers/). CUDA 13.4 corresponde a la rama R615; CUDA 13.x admite compatibilidad menor desde R580 con limitaciones. La opción sencilla es usar un controlador actual compatible con tu tarjeta. Consulta las [notas de NVIDIA](https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html).

Si Windows indica que falta `VCRUNTIME140.dll` o `MSVCP140.dll`, instala el [Microsoft Visual C++ Redistributable x64](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist). No descargues DLL sueltas de páginas desconocidas. Para ejecutar estos binarios no necesitas instalar todo el CUDA Toolkit: el paquete de dependencias del paso 3 aporta las bibliotecas CUDA.

### Equipo y resultados de referencia

Se probó una **RTX 5070 de 12 GB**, **Ryzen 9 5900X** y **64 GB de RAM**, con el GGUF Q4_K_M indicado abajo. Los resultados comunicados fueron **36,38 tokens/s en generación larga** y **3908 MiB de VRAM total ocupada con un contexto de 65536 configurado**. Ese contexto **no estaba lleno**. VRAM total ocupada incluye otros usos de la GPU; no equivale exclusivamente a memoria del modelo.

Estas cifras son una referencia de esa prueba, no una garantía ni un benchmark normalizado de esta release. No permiten deducir el consumo al llenar 64K, el tiempo de carga, la velocidad de otros equipos ni la memoria mínima necesaria. La posibilidad de usar **6 GB de VRAM y 32 GB de RAM es una hipótesis aún no probada**.

## 2. Elige tus carpetas

Descarga esta guía y abre PowerShell dentro de su carpeta: en el Explorador, entra en ella, escribe `powershell` en la barra de dirección y pulsa Enter.

En los ejemplos se usa `C:\IA\Qwen36`. Puedes cambiarlo por otra unidad con espacio libre. Mantén las comillas si la ruta contiene espacios. No uses una carpeta donde ya tengas otra instalación de llama.cpp.

Ejecuta primero:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
$Base = 'C:\IA\Qwen36'
$Llama = Join-Path $Base 'llama-b11559-cuda13.4'
$Modelos = Join-Path $Base 'modelos'
$Modelo = Join-Path $Modelos 'Qwen3.6-35B-A3B-Q4_K_M.gguf'
```

El cambio de política solo afecta a esta ventana. Si tu organización lo bloquea, consulta con su administrador. Al abrir otra ventana, repite las variables anteriores.

## 3. Instala llama.cpp y las dependencias

La guía fija la [release oficial b11559](https://github.com/ggml-org/llama.cpp/releases/tag/b11559), commit `f2cc7282c`, con CUDA **13.4**, Windows **x64**. No depende de un enlace cambiante a «latest».

```powershell
.\scripts\Install-Llama.ps1 -InstallRoot $Base
```

El script descarga estos dos ZIP desde la misma release, verifica sus SHA256 y los descomprime en una carpeta nueva:

- `llama-b11559-bin-win-cuda-13.4-x64.zip`
- `cudart-llama-bin-win-cuda-13.4-x64.zip`

Puedes ejecutarlo de nuevo: verifica la instalación existente y no la reemplaza. Si encuentra una carpeta ajena o archivos modificados, se detiene. Las descargas quedan en `downloads-b11559`; no hacen falta para conversar.

Para hacerlo manualmente, descarga ambos ZIP desde esa release y extrae su contenido en **una misma carpeta nueva**. No mezcles bibliotecas de distintas releases. Comprueba los hashes indicados en [DESCARGAS.md](DESCARGAS.md). El script de inicio también funciona con esa carpeta manual.

## 4. Descarga el modelo exacto

```powershell
.\scripts\Download-Model.ps1 -ModelDir $Modelos
```

La fuente es [ggml-org/Qwen3.6-35B-A3B-GGUF](https://huggingface.co/ggml-org/Qwen3.6-35B-A3B-GGUF/tree/baec3ebee244827cda0f4557eafa8b28f7545fa6). Se fija una revisión y se comprueba el SHA256 del archivo completo. La descarga puede tardar según tu conexión.

El archivo es `Qwen3.6-35B-A3B-Q4_K_M.gguf`, de **20 419 565 568 bytes**, equivalentes a **19,0172 GiB**, redondeados a **19,02 GiB**. No confundas GB decimales con GiB.

Otros repositorios pueden ofrecer archivos llamados Q4_K_M con tamaños y contenido distintos. No sustituyas el modelo por Qwen3.5, Qwen3.8, una variante modificada o un archivo MTP. Esta guía usa un único GGUF para texto, sin modelo draft ni proyector de imágenes.

Si ya tienes ese archivo, ponlo en la carpeta elegida y ejecuta el mismo script: lo verifica sin volver a descargarlo ni sobrescribirlo. Si una descarga falla, conserva el archivo `.part`; retíralo manualmente antes de repetir. No se reanuda automáticamente.

## 5. Comprueba la GPU

```powershell
nvidia-smi
& "$Llama\llama-server.exe" --version
& "$Llama\llama-server.exe" --list-devices
```

La versión debe indicar `build 11559`. La lista debe mostrar al menos un dispositivo CUDA y el nombre de tu NVIDIA. Elige el identificador de **esa lista**, por ejemplo:

```powershell
$GPU = 'CUDA0'
```

Con varias GPUs, no supongas que los índices de `nvidia-smi` y llama.cpp coinciden. Si la tarjeta que quieres usar aparece como `CUDA1`, cambia la variable. Se usará una sola GPU.

## 6. Abre el chat con 8192 tokens

```powershell
.\scripts\Start-Chat.ps1 -LlamaDir $Llama -ModelPath $Modelo -Device $GPU
```

Espera a que el servidor termine de cargar y abre [http://127.0.0.1:8080](http://127.0.0.1:8080) en tu navegador. Escribe una pregunta breve para comprobar la respuesta. Conserva PowerShell abierta y pulsa **Ctrl+C** para detener el servidor. El servidor escucha solo en tu ordenador.

El script comienza con **8192 tokens de contexto** y una conversación simultánea. El contexto incluye instrucciones, historial, pregunta y respuesta. Una conversación demasiado larga puede agotar ese espacio.

### Qué hacen los parámetros de memoria

- `--cpu-moe`: mantiene los pesos de los expertos MoE en RAM y los procesa en CPU.
- `--moe-cache-mib 0`: **desactiva** la caché de expertos en GPU. El cero no significa caché ilimitada ni automática en esta release.
- `-ngl 99`: permite llevar las capas restantes a GPU; `--cpu-moe` mantiene los expertos en CPU.
- `--device CUDA0 --split-mode none`: selecciona una sola GPU; usa tu identificador real.
- `--fit off`: conserva el contexto pedido y evita que el ajuste automático lo reduzca.
- `-fa on -ctk q8_0 -ctv q8_0`: activa Flash Attention y usa caché KV cuantizada. La caché KV guarda información de la conversación y es distinta de la caché de expertos.

La ayuda de la [release fijada](https://github.com/ggml-org/llama.cpp/tree/b11559) es la referencia para esta sintaxis. Estos parámetros no eliminan el consumo de RAM ni garantizan que el modelo quepa en cualquier tarjeta.

### Contexto opcional de 65536

Detén antes el servidor con Ctrl+C y ejecuta:

```powershell
.\scripts\Start-Chat.ps1 -LlamaDir $Llama -ModelPath $Modelo -Device $GPU -Context 65536
```

64K es una capacidad configurada, no una prueba con 64K tokens utilizados. Empieza por 8192; usa 65536 solo si necesitas ese espacio y compruebas la memoria disponible. Si falla la reserva, vuelve a 8192.

## 7. Sampling recomendado

Sampling controla cómo se elige cada token. Estos valores proceden de la [ficha oficial de Qwen3.6-35B-A3B](https://huggingface.co/Qwen/Qwen3.6-35B-A3B/blob/995ad96eacd98c81ed38be0c5b274b04031597b0/README.md).

| Perfil | Razonamiento | Temperatura | Top-p | Top-k | Min-p | Presence penalty | Repeat penalty |
|---|---|---:|---:|---:|---:|---:|---:|
| General | Activado | 1,0 | 0,95 | 20 | 0 | 1,5 | 1,0 |
| Coding | Activado | 0,6 | 0,95 | 20 | 0 | 0 | 1,0 |
| Instruct | Desactivado | 0,7 | 0,80 | 20 | 0 | 1,5 | 1,0 |

General es el perfil inicial. Para cambiarlo, detén el servidor y añade `-Sampling Coding` o `-Sampling Instruct`:

```powershell
.\scripts\Start-Chat.ps1 -LlamaDir $Llama -ModelPath $Modelo -Device $GPU -Sampling Coding
```

Los scripts usan punto decimal porque la línea de comandos lo requiere. En el navegador revisa los ajustes de la conversación: los valores enviados por la interfaz pueden sustituir los del servidor. Aplica la fila elegida y evita reutilizar ajustes guardados de otro modelo. El servidor usa `--reasoning on` para General/Coding y `--reasoning off` para Instruct.

## 8. Mide la velocidad en tu equipo

Con el servidor abierto, abre otra PowerShell en la carpeta de la guía:

```powershell
.\scripts\Benchmark.ps1 -Tokens 512 -Repeats 3
.\scripts\Benchmark.ps1 -Tokens 4096 -Repeats 3
```

El script hace un calentamiento y después las repeticiones solicitadas. Usa una petición de completado de texto, semilla 42, temperatura 0, sin reutilizar el prompt y con `ignore_eos` para medir una generación de longitud fija. Es una prueba sintética; no reproduce el sampling del chat ni la prueba histórica de 36,38 tokens/s.

La tabla muestra tokens realmente generados y tokens/s de generación, separados de los tokens del prompt. Una generación larga puede tardar; no uses el chat al mismo tiempo. Detén con Ctrl+C si necesitas interrumpir la petición. No presupongas que la carga del servidor se cancela inmediatamente.

En otra ventana puedes consultar la ocupación total de cada GPU:

```powershell
nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv -l 1
```

Registra GPU, CPU, RAM, controlador, versión de llama.cpp, modelo/hash, contexto, tokens generados y otras aplicaciones abiertas. Para comparar resultados, mantén estos elementos iguales. Configurar 65536 y enviar un prompt corto no mide un contexto lleno.

## 9. Si algo falla

| Problema | Qué comprobar |
|---|---|
| No aparece CUDA | Controlador NVIDIA, ZIP x64 CUDA 13.4 y dependencias de la misma release. Consulta `--list-devices`. |
| Falta una DLL CUDA | Extrae también el ZIP `cudart` en la carpeta de los ejecutables. No copies DLL de otra instalación. |
| Falta VCRUNTIME/MSVCP | Instala Visual C++ Redistributable x64 de Microsoft. |
| `unknown argument` | Comprueba `--version`: esta guía requiere b11559. No uses un ejecutable encontrado en otra carpeta. |
| Memoria insuficiente/CUDA OOM | Cierra aplicaciones que ocupen GPU y vuelve a contexto 8192. Comprueba también RAM y memoria comprometida de Windows. |
| Velocidad baja o disco trabajando continuamente | El modelo puede estar paginando. Comprueba RAM disponible; un archivo de paginación no sustituye una prueba con suficiente RAM. |
| SHA256 incorrecto | No ejecutes el archivo. El script se detiene sin reemplazarlo. Elige una carpeta nueva o retira manualmente la descarga incorrecta. |
| Puerto ocupado | Añade `-Port 8081` al inicio y al benchmark; abre `http://127.0.0.1:8081`. |
| Navegador sin conexión | Espera a la carga, revisa PowerShell y prueba `/health` en la misma dirección. Debe mostrar estado `ok`. |
| Respuesta repetitiva o extraña | Revisa perfil, razonamiento y ajustes enviados por el navegador; inicia una conversación nueva. |

Para revisar versión, modelo, dispositivo y argumentos sin cargar el modelo:

```powershell
.\scripts\Start-Chat.ps1 -LlamaDir $Llama -ModelPath $Modelo -Device $GPU -CheckOnly
```

El instalador conserva instalaciones anteriores. Para otra release, elige otra carpeta y revisa sus parámetros antes de usarla.
