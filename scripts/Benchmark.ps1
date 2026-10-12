[CmdletBinding()]
param(
    [ValidateRange(1,65535)][int]$Port=8080,
    [ValidateRange(1,4096)][int]$Tokens=512,
    [ValidateRange(1,10)][int]$Repeats=3
)
$ErrorActionPreference = 'Stop'
$url = "http://127.0.0.1:$Port"
$health = Invoke-RestMethod "$url/health"
if ($health.status -ne 'ok') { throw 'El servidor todavia no esta listo.' }
$body = @{prompt='Write a detailed fictional travel journal. Continue until the token limit.'; n_predict=$Tokens;
    temperature=0; seed=42; ignore_eos=$true; cache_prompt=$false; stream=$false} | ConvertTo-Json
for ($i=0; $i -le $Repeats; $i++) {
    $result = Invoke-RestMethod "$url/completion" -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 3600
    if ($i -eq 0) { Write-Host 'Calentamiento completado.'; continue }
    [pscustomobject]@{Repeticion=$i; PromptTokens=$result.timings.prompt_n; Generados=$result.timings.predicted_n;
        TokensPorSegundo=$result.timings.predicted_per_second; GeneracionMs=$result.timings.predicted_ms}
}
