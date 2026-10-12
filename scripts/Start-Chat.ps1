[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$LlamaDir,
    [Parameter(Mandatory=$true)][string]$ModelPath,
    [string]$Device = 'CUDA0',
    [ValidateSet(8192,65536)][int]$Context = 8192,
    [ValidateRange(1,65535)][int]$Port = 8080,
    [ValidateSet('General','Coding','Instruct')][string]$Sampling = 'General',
    [switch]$CheckOnly
)
. "$PSScriptRoot/Common.ps1"
$exe = Join-Path ([IO.Path]::GetFullPath($LlamaDir)) 'llama-server.exe'
if (!(Test-Path -LiteralPath $exe)) { throw 'No se encuentra llama-server.exe. Revisa LlamaDir.' }
Assert-Model $ModelPath
$ErrorActionPreference = 'Continue'
$version = (& $exe --version 2>&1 | Out-String)
$ErrorActionPreference = 'Stop'
if ($LASTEXITCODE -ne 0 -or $version -notmatch 'build 11559') { throw 'Usa la release b11559 instalada por Install-Llama.ps1.' }
$ErrorActionPreference = 'Continue'
$devices = (& $exe --list-devices 2>&1 | Out-String)
$ErrorActionPreference = 'Stop'
if ($LASTEXITCODE -ne 0 -or $Device -notmatch '^CUDA\d+$' -or $devices -notmatch ('(?m)^\s*' + [regex]::Escape($Device) + ':')) {
    throw "Dispositivo CUDA no disponible: $Device`n$devices"
}
$temp = '1.0'; $topP = '0.95'; $presence = '1.5'; $thinking = 'on'
if ($Sampling -eq 'Coding') { $temp = '0.6'; $presence = '0.0' }
if ($Sampling -eq 'Instruct') { $temp = '0.7'; $topP = '0.80'; $thinking = 'off' }
$arguments = @('-m',[IO.Path]::GetFullPath($ModelPath),'--device',$Device,'-ngl','99','--split-mode','none',
    '--fit','off','--cpu-moe','--moe-cache-mib','0','-c',"$Context",'-np','1','-fa','on',
    '-ctk','q8_0','-ctv','q8_0','-b','512','-ub','128','--jinja',
    '--reasoning',$thinking,
    '--temp',$temp,'--top-p',$topP,'--top-k','20','--min-p','0',
    '--presence-penalty',$presence,'--repeat-penalty','1.0','--host','127.0.0.1','--port',"$Port")
Write-Host $version.Trim()
Write-Host $devices.Trim()
Write-Host "Navegador: http://127.0.0.1:$Port (cuando termine de cargar). Detener: Ctrl+C."
if ($CheckOnly) { $arguments; return }
$listener = New-Object Net.Sockets.TcpListener([Net.IPAddress]::Loopback,$Port)
try { $listener.Start() } catch { throw "Puerto $Port ocupado. Usa -Port 8081." } finally { $listener.Stop() }
& $exe @arguments
if ($LASTEXITCODE -ne 0) { throw "llama-server termino con codigo $LASTEXITCODE. Revisa el mensaje anterior." }
