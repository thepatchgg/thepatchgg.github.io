$repoRoot = Split-Path -Parent $PSScriptRoot

function Run-Check {
  param([string]$ScriptPath)

  $output = & powershell -ExecutionPolicy Bypass -File $ScriptPath 2>&1
  $code = $LASTEXITCODE

  [pscustomobject]@{
    path = $ScriptPath
    exitCode = $code
    output = ($output -join [Environment]::NewLine).Trim()
  }
}

Push-Location $repoRoot
try {
  $branch = (& "C:\Program Files\Git\cmd\git.exe" rev-parse --abbrev-ref HEAD).Trim()
  $commit = (& "C:\Program Files\Git\cmd\git.exe" rev-parse --short HEAD).Trim()
  $statusLines = & "C:\Program Files\Git\cmd\git.exe" status --short
  $status = if ($statusLines) { ($statusLines -join [Environment]::NewLine).Trim() } else { "" }
} finally {
  Pop-Location
}

$siteQa = Run-Check -ScriptPath (Join-Path $PSScriptRoot "qa-site.ps1")
$releaseQa = Run-Check -ScriptPath (Join-Path $PSScriptRoot "qa-release.ps1")

$screensDir = Join-Path $repoRoot "qa-screenshots"
$screenCount = if (Test-Path -LiteralPath $screensDir) {
  (Get-ChildItem -Path $screensDir -Filter *.png -File | Measure-Object).Count
} else {
  0
}

$manualTemplate = Join-Path $repoRoot "MANUAL_QA_REPORT_TEMPLATE.md"
$manualTemplateExists = Test-Path -LiteralPath $manualTemplate

Write-Output "Branch: $branch"
Write-Output "Commit: $commit"
Write-Output ("Worktree clean: {0}" -f [string]::IsNullOrWhiteSpace($status))
Write-Output ""
Write-Output "qa-site.ps1:"
Write-Output $siteQa.output
Write-Output ""
Write-Output "qa-release.ps1:"
Write-Output $releaseQa.output
Write-Output ""
Write-Output "Screenshot count: $screenCount"
Write-Output "Manual QA template present: $manualTemplateExists"

if (-not [string]::IsNullOrWhiteSpace($status)) {
  Write-Output ""
  Write-Output "Uncommitted changes:"
  Write-Output $status
}
