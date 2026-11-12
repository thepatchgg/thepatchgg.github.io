param(
  [string]$OutReport = "data/new-egg-coverage-audit.md"
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

function Get-CheckMark([bool]$Value) {
  if ($Value) { return "Yes" }
  return "No"
}

function Get-IdSetFromBlock([string]$Text, [string]$StartMarker, [string]$EndMarker) {
  $startIndex = $Text.IndexOf($StartMarker)
  if ($startIndex -lt 0) {
    return @()
  }

  $tail = $Text.Substring($startIndex + $StartMarker.Length)
  if (-not [string]::IsNullOrWhiteSpace($EndMarker)) {
    $endIndex = $tail.IndexOf($EndMarker)
    if ($endIndex -ge 0) {
      $tail = $tail.Substring(0, $endIndex)
    }
  }

  $ids = New-Object System.Collections.Generic.List[string]
  foreach ($match in [regex]::Matches($tail, '(?:"id"|id)\s*:\s*"([^"]+)"')) {
    $ids.Add($match.Groups[1].Value)
  }

  return @($ids | Select-Object -Unique)
}

function Get-KeySetFromBlock([string]$Text, [string]$StartMarker, [string]$EndMarker) {
  $startIndex = $Text.IndexOf($StartMarker)
  if ($startIndex -lt 0) {
    return @()
  }

  $tail = $Text.Substring($startIndex + $StartMarker.Length)
  if (-not [string]::IsNullOrWhiteSpace($EndMarker)) {
    $endIndex = $tail.IndexOf($EndMarker)
    if ($endIndex -ge 0) {
      $tail = $tail.Substring(0, $endIndex)
    }
  }

  $ids = New-Object System.Collections.Generic.List[string]
  foreach ($match in [regex]::Matches($tail, '(?m)^    ([a-z0-9-]+):\s*\{')) {
    $ids.Add($match.Groups[1].Value)
  }

  return @($ids | Select-Object -Unique)
}

function Parse-Bool($Text, [string]$Pattern) {
  return ($Text -match $Pattern)
}

$eggsPath = Resolve-RepoPath "data/adopt-me-eggs.json"
$verifiedPath = Resolve-RepoPath "data/adopt-me-verified-eggs.json"
$guidePath = Resolve-RepoPath "articles/adopt-me-egg-guide.html"
$calculatorPath = Resolve-RepoPath "egg-value-calculator.html"
$guideJsPath = Resolve-RepoPath "assets/js/adopt-eggs.js"
$guideDataJsPath = Resolve-RepoPath "assets/js/adopt-egg-guide-data.js"
$assetsDir = Resolve-RepoPath "assets/eggs"
$reportPath = Resolve-RepoPath $OutReport

$eggsPayload = Get-Content -Raw -LiteralPath $eggsPath | ConvertFrom-Json
$verifiedPayload = Get-Content -Raw -LiteralPath $verifiedPath | ConvertFrom-Json
$guideContent = Get-Content -Raw -LiteralPath $guidePath
$calculatorContent = Get-Content -Raw -LiteralPath $calculatorPath
$guideJsContent = Get-Content -Raw -LiteralPath $guideJsPath
$guideDataJsContent = Get-Content -Raw -LiteralPath $guideDataJsPath

$guideDataCorrectedIds = Get-KeySetFromBlock $guideDataJsContent 'correctedEggs: {' 'extraEggs: ['
$guideDataExtraIds = Get-IdSetFromBlock $guideDataJsContent 'extraEggs: [' ''
$guideDataIds = @($guideDataCorrectedIds + $guideDataExtraIds | Select-Object -Unique)

$guideOrderMatch = [regex]::Match($guideContent, 'EGG_GUIDE_ORDER\s*=\s*\[(?s)(.*?)\]', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$guideOrderIds = if ($guideOrderMatch.Success) {
  @([regex]::Matches($guideOrderMatch.Groups[1].Value, '"([a-z0-9-]+)"') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
} else {
  @()
}

$exactIdsMatch = [regex]::Match($guideJsContent, 'LOCAL_EXACT_EGG_IDS\s*=\s*new Set\(\[(?s)(.*?)\]\)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$localExactIds = if ($exactIdsMatch.Success) {
  @([regex]::Matches($exactIdsMatch.Groups[1].Value, '"([a-z0-9-]+)"') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
} else {
  @()
}

$eggIndex = @{}
foreach ($egg in $eggsPayload.eggs) {
  $eggIndex[$egg.id] = $egg
}

$verifiedIndex = @{}
foreach ($egg in $verifiedPayload.eggs) {
  $verifiedIndex[$egg.id] = $egg
}

$allIds = New-Object System.Collections.Generic.HashSet[string]
foreach ($id in $eggIndex.Keys) { [void]$allIds.Add($id) }
foreach ($id in $verifiedIndex.Keys) { [void]$allIds.Add($id) }

$rows = New-Object System.Collections.Generic.List[object]
$notes = New-Object System.Collections.Generic.List[string]

foreach ($id in ($allIds | Sort-Object)) {
  $egg = if ($eggIndex.ContainsKey($id)) { $eggIndex[$id] } else { $null }
  $verifiedEgg = if ($verifiedIndex.ContainsKey($id)) { $verifiedIndex[$id] } else { $null }
  $eggName = if ($null -ne $egg) { [string]$egg.name } elseif ($null -ne $verifiedEgg) { [string]$verifiedEgg.name } else { $id }

  $inGuideData = $guideDataIds -contains $id
  $inGuideOrder = $guideOrderIds -contains $id
  $hasLocalExactArt = $localExactIds -contains $id
  $imageExtension = if ($id -eq 'fairytale') { 'png' } else { 'webp' }
  $localExactArtExists = if ($hasLocalExactArt) { Test-Path -LiteralPath (Join-Path $assetsDir "$id.$imageExtension") } else { $true }

  $missing = @()
  if ($null -eq $egg) { $missing += "main egg dataset" }
  if ($null -eq $verifiedEgg) { $missing += "verified egg dataset" }
  if (-not $inGuideOrder) { $missing += "egg guide order" }
  if (-not $localExactArtExists) { $missing += "local exact egg art" }

  if ($missing.Count -gt 0) {
    $notes.Add("- **$eggName** ($id): missing $($missing -join ', ')")
  }

  $rows.Add([pscustomobject]@{
    Id = $id
    Name = $eggName
    InMainDataset = $null -ne $egg
    InVerifiedDataset = $null -ne $verifiedEgg
    InGuideData = $inGuideData
    InGuideOrder = $inGuideOrder
    LocalExactArt = $hasLocalExactArt -and $localExactArtExists
  }) | Out-Null
}

$sharedCount = @($rows | Where-Object { $_.InMainDataset -and $_.InVerifiedDataset }).Count
$mainOnlyCount = @($rows | Where-Object { $_.InMainDataset -and -not $_.InVerifiedDataset }).Count
$verifiedOnlyCount = @($rows | Where-Object { -not $_.InMainDataset -and $_.InVerifiedDataset }).Count
$guideDataCount = @($rows | Where-Object { $_.InGuideData }).Count
$guideOrderCount = @($rows | Where-Object { $_.InGuideOrder }).Count
$localExactCount = @($rows | Where-Object { $_.LocalExactArt }).Count
$calculatorWired = Parse-Bool $calculatorContent 'window\.ThePatchEggs\.loadEggs\(window\.ThePatchEggs\.FULL_DATA_PATH\)' -and (Parse-Bool $calculatorContent 'window\.ThePatchValues\.loadAdoptValues\(\)')
$guideWired = (Parse-Bool $guideContent '/assets/js/adopt-eggs.js') -and (Parse-Bool $guideContent '/assets/js/adopt-egg-guide-data.js') -and ($guideOrderIds.Count -gt 0)

$report = New-Object System.Collections.Generic.List[string]
$report.Add("# New Egg Coverage Audit")
$report.Add("")
$report.Add("- Date: $(Get-Date -Format 'yyyy-MM-dd')")
$report.Add("- Main egg records: $($eggsPayload.eggs.Count)")
$report.Add("- Verified egg records: $($verifiedPayload.eggs.Count)")
$report.Add("- Shared egg IDs: $sharedCount")
$report.Add("- Main-only egg IDs: $mainOnlyCount")
$report.Add("- Verified-only egg IDs: $verifiedOnlyCount")
$report.Add("- Guide data IDs covered: $guideDataCount")
$report.Add("- Guide order IDs covered: $guideOrderCount")
$report.Add("- Local exact egg art IDs covered: $localExactCount")
$report.Add("- Guide wiring present: $(Get-CheckMark $guideWired)")
$report.Add("- Calculator wiring present: $(Get-CheckMark $calculatorWired)")
$report.Add("")
$report.Add("| Egg | Main | Verified | Guide Data | Guide Order | Local Exact Art |")
$report.Add("| --- | --- | --- | --- | --- | --- |")

foreach ($row in $rows) {
  $report.Add("| $($row.Name) | $(Get-CheckMark $row.InMainDataset) | $(Get-CheckMark $row.InVerifiedDataset) | $(Get-CheckMark $row.InGuideData) | $(Get-CheckMark $row.InGuideOrder) | $(Get-CheckMark $row.LocalExactArt) |")
}

$report.Add("")
$report.Add("## Notes")
$report.Add("")

if ($notes.Count -eq 0) {
  $report.Add("- No egg coverage gaps detected in the checked layers.")
} else {
  foreach ($note in $notes) {
    $report.Add($note)
  }
}

$report | Set-Content -LiteralPath $reportPath

Write-Output ("report={0} shared={1} main_only={2} verified_only={3}" -f $reportPath, $sharedCount, $mainOnlyCount, $verifiedOnlyCount)
