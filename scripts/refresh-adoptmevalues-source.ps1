param(
  [string]$Url = "https://www.adoptmevalues.app/values",
  [string]$OutPath = "data/adoptmevalues-values-page.html",
  [int]$TimeoutSec = 60
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

function Resolve-RepoPath([string]$Path) {
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }

  return Join-Path $repoRoot $Path.Replace("/", "\")
}

$resolvedOutPath = Resolve-RepoPath $OutPath
$outDir = Split-Path -Parent $resolvedOutPath
if (-not (Test-Path -LiteralPath $outDir)) {
  New-Item -ItemType Directory -Path $outDir | Out-Null
}

$curl = Get-Command curl.exe -ErrorAction SilentlyContinue
if (-not $curl) {
  throw "curl.exe is required for tracker fetches on this workflow."
}

$tempPath = [System.IO.Path]::GetTempFileName()
try {
  & $curl.Source `
    --silent `
    --show-error `
    --fail `
    --location `
    --max-time $TimeoutSec `
    --compressed `
    --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36" `
    --output $tempPath `
    $Url

  if ($LASTEXITCODE -ne 0) {
    throw "curl exited with code $LASTEXITCODE"
  }

  $content = Get-Content -LiteralPath $tempPath -Raw
  if ([string]::IsNullOrWhiteSpace($content)) {
    throw "Fetched tracker page was empty."
  }

  $content | Set-Content -LiteralPath $resolvedOutPath -Encoding UTF8
} finally {
  if (Test-Path -LiteralPath $tempPath) {
    Remove-Item -LiteralPath $tempPath -Force
  }
}

Write-Output ("source_refreshed=1 path={0}" -f $resolvedOutPath)
