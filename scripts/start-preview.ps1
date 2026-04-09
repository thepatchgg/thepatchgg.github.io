param(
  [int]$Port = 4173,
  [string]$BindHost = "127.0.0.1",
  [switch]$NoDetach
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$pidFile = Join-Path $repoRoot ".preview-server.json"
$pythonPath = (Get-Command python -ErrorAction Stop).Source

function Get-PortListener {
  param(
    [string]$BindHost,
    [int]$BindPort
  )

  try {
    return Get-NetTCPConnection -LocalAddress $BindHost -LocalPort $BindPort -State Listen -ErrorAction Stop
  } catch {
    return $null
  }
}

$listener = Get-PortListener -BindHost $BindHost -BindPort $Port
if ($listener) {
  throw "Port $Port is already in use on $BindHost."
}

$pythonArgs = @("-m", "http.server", $Port, "--bind", $BindHost)

if ($NoDetach) {
  Write-Output "Starting preview server at http://$BindHost`:$Port/"
  Push-Location $repoRoot
  try {
    & python @pythonArgs
  } finally {
    Pop-Location
  }
  exit 0
}

$process = Start-Process -FilePath $pythonPath -ArgumentList $pythonArgs -WorkingDirectory $repoRoot -PassThru -WindowStyle Hidden

$details = [pscustomobject]@{
  pid = $process.Id
  host = $BindHost
  port = $Port
  url = "http://$BindHost`:$Port/"
  startedAt = (Get-Date).ToString("o")
}

$details | ConvertTo-Json | Set-Content -Path $pidFile -Encoding UTF8

Write-Output "Preview server started at $($details.url)"
Write-Output "PID: $($process.Id)"
Write-Output "State file: $pidFile"
