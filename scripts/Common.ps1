$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
function Assert-Hash([string]$Path, [string]$Hash) {
    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Falta el archivo: $Path" }
    if ((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash -ne $Hash) {
        throw "SHA256 incorrecto: $Path. No se sobrescribira; elige otra carpeta o retira manualmente el archivo incorrecto."
    }
}
function Get-VerifiedFile([string]$Url, [string]$Path, [string]$Hash) {
    if (Test-Path -LiteralPath $Path) { Assert-Hash $Path $Hash; return }
    $partial = "$Path.part"
    if (Test-Path -LiteralPath $partial) { throw "Descarga incompleta: $partial. Retirala manualmente y repite."
    }
    & curl.exe --fail --location --retry 3 --output $partial $Url
    if ($LASTEXITCODE -ne 0) { throw "Descarga fallida. Conservado: $partial" }
    Assert-Hash $partial $Hash
    Move-Item -LiteralPath $partial -Destination $Path
}
function Assert-Model([string]$Path) {
    $file = Get-Item -LiteralPath $Path
    if ($file.Length -ne 20419565568) { throw 'El modelo no tiene el tamano esperado para el GGUF fijado. Ejecuta Download-Model.ps1 para verificarlo.' }
    $stream = [IO.File]::OpenRead($file.FullName)
    try {
        $bytes = New-Object byte[] 4
        [void]$stream.Read($bytes,0,4)
        if ([Text.Encoding]::ASCII.GetString($bytes) -ne 'GGUF') { throw 'El archivo no es GGUF.' }
    } finally { $stream.Dispose() }
}
