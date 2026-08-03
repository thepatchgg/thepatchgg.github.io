$repoRoot = Split-Path -Parent $PSScriptRoot

$htmlFiles = Get-ChildItem -Path $repoRoot -Recurse -Filter *.html |
  Where-Object { $_.FullName -notlike (Join-Path $repoRoot 'data\*') } |
  Sort-Object FullName
$issues = New-Object System.Collections.Generic.List[string]

function Resolve-InternalTarget {
  param(
    [string]$CurrentFile,
    [string]$Reference
  )

  if ([string]::IsNullOrWhiteSpace($Reference)) {
    return $null
  }

  if ($Reference -match '\$\{|\{.+\}') {
    return $null
  }

  if ($Reference -match '^(https?:|mailto:|tel:|data:|javascript:|#)') {
    return $null
  }

  $clean = $Reference.Split('#')[0].Split('?')[0]
  if ([string]::IsNullOrWhiteSpace($clean)) {
    return $null
  }

  if ($clean.StartsWith('/')) {
    if ($clean -eq '/') {
      return Join-Path $repoRoot 'index.html'
    }

    return Join-Path $repoRoot $clean.TrimStart('/').Replace('/', '\')
  }

  $baseDir = Split-Path -Parent $CurrentFile
  return Join-Path $baseDir $clean.Replace('/', '\')
}

foreach ($file in $htmlFiles) {
  $content = Get-Content -Raw -Path $file.FullName
  $matches = [regex]::Matches($content, '(href|src)="([^"]+)"')

  foreach ($match in $matches) {
    $reference = $match.Groups[2].Value
    $target = Resolve-InternalTarget -CurrentFile $file.FullName -Reference $reference
    if (-not $target) {
      continue
    }

    if (-not (Test-Path -LiteralPath $target)) {
      $issues.Add("Missing target in $($file.Name): $reference")
    }
  }
}

$metadataTargets = @(
  Get-ChildItem -Path $repoRoot -Filter *.html
  Get-ChildItem -Path (Join-Path $repoRoot 'pets') -Filter *.html
)

foreach ($file in $metadataTargets) {
  $content = Get-Content -Raw -Path $file.FullName

  if ($content -notmatch '<title>.+</title>') {
    $issues.Add("Missing <title> in $($file.Name)")
  }
  if ($content -notmatch '<meta name="description" content="[^"]+') {
    $issues.Add("Missing meta description in $($file.Name)")
  }
  if ($content -notmatch '<link rel="canonical" href="https://thepatchgg\.github\.io/[^"]*"') {
    $issues.Add("Missing canonical in $($file.Name)")
  }
  if ($content -notmatch '<link rel="icon" href="/favicon\.svg"') {
    $issues.Add("Missing favicon in $($file.Name)")
  }
  if ($content -notmatch '<link rel="manifest" href="/site\.webmanifest"') {
    $issues.Add("Missing manifest in $($file.Name)")
  }
  if ($content -notmatch '<meta name="theme-color" content="#08111f"') {
    $issues.Add("Missing theme-color in $($file.Name)")
  }
}

if ($issues.Count -gt 0) {
  $issues | ForEach-Object { Write-Output $_ }
  exit 1
}

Write-Output ("QA passed for {0} HTML files." -f $htmlFiles.Count)
