[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$ModelDir)
. "$PSScriptRoot/Common.ps1"
$dir = [IO.Path]::GetFullPath($ModelDir)
New-Item -ItemType Directory -Path $dir -Force | Out-Null
$path = Join-Path $dir 'Qwen3.6-35B-A3B-Q4_K_M.gguf'
$url = 'https://huggingface.co/ggml-org/Qwen3.6-35B-A3B-GGUF/resolve/baec3ebee244827cda0f4557eafa8b28f7545fa6/Qwen3.6-35B-A3B-Q4_K_M.gguf?download=true'
Get-VerifiedFile $url $path '671e47e0ec53c665d048b98c3ecbfd5236b5ca9c3e02ed19fc8f81f7b85140c7'
Assert-Model $path
Write-Host "Modelo verificado: $path"
