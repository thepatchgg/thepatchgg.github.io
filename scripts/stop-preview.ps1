$repoRoot = Split-Path -Parent $PSScriptRoot
$pidFile = Join-Path $repoRoot ".preview-server.json"

if (-not (Test-Path -LiteralPath $pidFile)) {
  Write-Output "No preview server state file found."
  exit 0
}

$details = Get-Content -Raw -Path $pidFile | ConvertFrom-Json

if ($details.pid) {
  $process = Get-Process -Id $details.pid -ErrorAction SilentlyContinue
  if ($process) {
    Stop-Process -Id $details.pid -Force
    Write-Output "Stopped preview server PID $($details.pid)."
  } else {
    Write-Output "Preview server process $($details.pid) was not running."
  }
}

Remove-Item -LiteralPath $pidFile -Force
