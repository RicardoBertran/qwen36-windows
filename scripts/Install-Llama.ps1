[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$InstallRoot)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/Common.ps1"
$root = [IO.Path]::GetFullPath($InstallRoot)
New-Item -ItemType Directory -Path $root -Force | Out-Null
$dest = Join-Path $root 'llama-b11559-cuda13.4'
$manifest = Join-Path $dest 'installed-files.json'
if (Test-Path -LiteralPath $dest) {
    if (!(Test-Path -LiteralPath $manifest)) { throw 'La carpeta ya existe sin verificacion. Elige otra ruta; no se sobrescribira.' }
    foreach ($entry in (Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json)) {
        Assert-Hash (Join-Path $dest $entry.Path) $entry.Hash
    }
    Write-Host "Instalacion ya verificada: $dest"
    return
}
$stage = Join-Path $root ('stage-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stage | Out-Null
$packages = @(
    @{Name='llama-b11559-bin-win-cuda-13.4-x64.zip'; Hash='419de1292bcb772824fec45e4bc3722e79459e8d89c552578bafdad51266294a'},
    @{Name='cudart-llama-bin-win-cuda-13.4-x64.zip'; Hash='738f8c251ac22b70c3ae6f83a10cf222725df0395246a2cf58f32bdb85fbe668'}
)
$cache = Join-Path $root 'downloads-b11559'
New-Item -ItemType Directory -Path $cache -Force | Out-Null
foreach ($p in $packages) {
    $zip = Join-Path $cache $p.Name
    Get-VerifiedFile "https://github.com/ggml-org/llama.cpp/releases/download/b11559/$($p.Name)" $zip $p.Hash
    Expand-Archive -LiteralPath $zip -DestinationPath $stage
}
$exe = Join-Path $stage 'llama-server.exe'
if (!(Test-Path -LiteralPath $exe)) { throw 'No se encontro llama-server.exe.' }
& $exe --version
if ($LASTEXITCODE -ne 0) { throw 'No se pudo ejecutar llama.cpp. Comprueba las dependencias de Windows.' }
$entries = @(Get-ChildItem -LiteralPath $stage -File -Recurse | ForEach-Object {
    @{Path=$_.FullName.Substring($stage.Length + 1); Hash=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}
})
ConvertTo-Json -InputObject $entries -Depth 3 | Set-Content -LiteralPath (Join-Path $stage 'installed-files.json') -Encoding UTF8
Move-Item -LiteralPath $stage -Destination $dest
Write-Host "Instalado: $dest"
