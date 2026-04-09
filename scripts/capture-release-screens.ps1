param(
  [int]$Port = 4173,
  [string]$BindHost = "127.0.0.1",
  [string]$OutputDir = "qa-screenshots",
  [string]$BrowserPath
)

$repoRoot = Split-Path -Parent $PSScriptRoot

function Resolve-Browser {
  param([string]$PreferredPath)

  $candidates = @()
  if ($PreferredPath) {
    $candidates += $PreferredPath
  }

  $candidates += @(
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
  )

  return $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}

function Invoke-Capture {
  param(
    [string]$Executable,
    [string]$Url,
    [string]$TargetPath,
    [string]$Viewport,
    [string]$UserDataDir
  )

  & $Executable `
    --headless=new `
    --disable-gpu `
    --disable-crash-reporter `
    --no-first-run `
    --no-default-browser-check `
    --hide-scrollbars `
    "--user-data-dir=$UserDataDir" `
    "--window-size=$Viewport" `
    "--screenshot=$TargetPath" `
    $Url 2>$null | Out-Null
}

$browser = Resolve-Browser -PreferredPath $BrowserPath
if (-not $browser) {
  throw "No supported Chromium-based browser was found."
}

$baseUrl = "http://$BindHost`:$Port"

try {
  Invoke-WebRequest -Uri "$baseUrl/" -UseBasicParsing -TimeoutSec 5 | Out-Null
} catch {
  throw "Preview server is not responding at $baseUrl. Start it before running screenshots."
}

$outputPath = Join-Path $repoRoot $OutputDir
if (-not (Test-Path -LiteralPath $outputPath)) {
  New-Item -ItemType Directory -Path $outputPath | Out-Null
}

$userDataDir = Join-Path $repoRoot ".headless-browser"
if (-not (Test-Path -LiteralPath $userDataDir)) {
  New-Item -ItemType Directory -Path $userDataDir | Out-Null
}

$targets = @(
  @{ Slug = "home"; Path = "/" },
  @{ Slug = "guides"; Path = "/adopt-me.html" },
  @{ Slug = "trade-calculator"; Path = "/pet-value-calculator.html" },
  @{ Slug = "neon-calculator"; Path = "/neon-calculator.html" },
  @{ Slug = "egg-calculator"; Path = "/egg-value-calculator.html" },
  @{ Slug = "market-movers"; Path = "/market-movers.html" },
  @{ Slug = "inventory-planner"; Path = "/inventory-planner.html" },
  @{ Slug = "value-list"; Path = "/articles/adopt-me-pet-value-list-2026.html" },
  @{ Slug = "pet-library"; Path = "/pets/" },
  @{ Slug = "bat-dragon"; Path = "/pets/bat-dragon.html" }
)

$viewports = @(
  @{ Name = "desktop"; Size = "1440,2400" },
  @{ Name = "mobile"; Size = "390,2200" }
)

foreach ($target in $targets) {
  foreach ($viewport in $viewports) {
    $fileName = "{0}-{1}.png" -f $target.Slug, $viewport.Name
    $screenshotPath = Join-Path $outputPath $fileName
    $url = "$baseUrl$($target.Path)"

    Invoke-Capture -Executable $browser -Url $url -TargetPath $screenshotPath -Viewport $viewport.Size -UserDataDir $userDataDir
    Write-Output "Captured $fileName"
  }
}

Write-Output "Screenshots saved to $outputPath"
