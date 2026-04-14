param(
  [string]$SourceHtml = "data/adoptmevalues-values-page.html",
  [string]$LegacyCatalog = "data/adopt-me-calculator-values.json",
  [string]$BenchmarkData = "data/adopt-me-values.json",
  [string]$ManualMappings = "data/adopt-me-calculator-manual-mappings.json",
  [string]$OutJson = "data/adopt-me-calculator-overrides.json",
  [string]$OutReport = "data/adopt-me-calculator-audit-report.md"
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

function Normalize-Key([string]$Text) {
  if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
  $normalized = $Text.ToLowerInvariant()
  $normalized = $normalized -replace "&amp;", "and"
  $normalized = $normalized -replace "\(pet\)", ""
  $normalized = $normalized -replace "[^a-z0-9]+", "-"
  return $normalized.Trim("-")
}

function Round-Value([double]$Value) {
  return [math]::Round($Value, 2)
}

function Build-Stage([object]$Item, [string]$Prefix) {
  $base = [double]$Item."${Prefix}value"
  $fly = [double]$Item."${Prefix}valueFly"
  $ride = [double]$Item."${Prefix}valueRide"
  $flyRide = [double]$Item."${Prefix}valueFlyRide"
  $noPotion = [double]$Item."${Prefix}valueNoPotion"

  if ($noPotion -le 0 -and $base -gt 0) { $noPotion = $base }
  if ($fly -le 0 -and $flyRide -gt 0) { $fly = $noPotion + (($flyRide - $noPotion) * 0.7) }
  if ($ride -le 0 -and $flyRide -gt 0) { $ride = $noPotion + (($flyRide - $noPotion) * 0.7) }
  if ($flyRide -le 0 -and $base -gt 0) { $flyRide = $base }
  if ($fly -le 0) { $fly = $noPotion }
  if ($ride -le 0) { $ride = $noPotion }
  if ($flyRide -le 0) { $flyRide = $noPotion }

  return [ordered]@{
    noPotion = (Round-Value $noPotion)
    fly = (Round-Value $fly)
    ride = (Round-Value $ride)
    flyRide = (Round-Value $flyRide)
  }
}

function Build-StageFromBase([double]$BaseValue, [double]$StageMultiplier) {
  $normal = $BaseValue * $StageMultiplier
  return [ordered]@{
    noPotion = (Round-Value $normal)
    fly = (Round-Value ($normal * 1.5))
    ride = (Round-Value ($normal * 1.5))
    flyRide = (Round-Value ($normal * 2))
  }
}

if (-not (Test-Path -LiteralPath (Resolve-RepoPath $SourceHtml))) {
  throw "Source HTML not found: $SourceHtml"
}

$raw = Get-Content -LiteralPath (Resolve-RepoPath $SourceHtml) -Raw
$rowPattern = '\\\"id\\\":\\\"(?<id>\d+)\\\".*?\\\"name\\\":\\\"(?<name>.*?)\\\".*?\\\"rarity\\\":\\\"(?<rarity>.*?)\\\".*?\\\"type\\\":\\\"(?<type>.*?)\\\".*?\\\"rvalue\\\":(?<rvalue>[0-9.]+).*?\\\"rvalueFly\\\":(?<rvalueFly>[0-9.]+).*?\\\"rvalueRide\\\":(?<rvalueRide>[0-9.]+).*?\\\"rvalueFlyRide\\\":(?<rvalueFlyRide>[0-9.]+).*?\\\"rvalueNoPotion\\\":(?<rvalueNoPotion>[0-9.]+).*?\\\"nvalue\\\":(?<nvalue>[0-9.]+).*?\\\"nvalueFly\\\":(?<nvalueFly>[0-9.]+).*?\\\"nvalueRide\\\":(?<nvalueRide>[0-9.]+).*?\\\"nvalueFlyRide\\\":(?<nvalueFlyRide>[0-9.]+).*?\\\"nvalueNoPotion\\\":(?<nvalueNoPotion>[0-9.]+).*?\\\"mvalue\\\":(?<mvalue>[0-9.]+).*?\\\"mvalueFly\\\":(?<mvalueFly>[0-9.]+).*?\\\"mvalueRide\\\":(?<mvalueRide>[0-9.]+).*?\\\"mvalueFlyRide\\\":(?<mvalueFlyRide>[0-9.]+).*?\\\"mvalueNoPotion\\\":(?<mvalueNoPotion>[0-9.]+)'
$matches = [regex]::Matches($raw, $rowPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

$trackerItems = New-Object System.Collections.Generic.List[object]
foreach ($match in $matches) {
  if ($match.Groups["type"].Value -ne "pets") {
    continue
  }

  $trackerItems.Add([pscustomobject]@{
    id = $match.Groups["id"].Value
    name = ($match.Groups["name"].Value -replace '\\u0026', '&')
    rarity = $match.Groups["rarity"].Value
    type = $match.Groups["type"].Value
    rvalue = [double]$match.Groups["rvalue"].Value
    rvalueFly = [double]$match.Groups["rvalueFly"].Value
    rvalueRide = [double]$match.Groups["rvalueRide"].Value
    rvalueFlyRide = [double]$match.Groups["rvalueFlyRide"].Value
    rvalueNoPotion = [double]$match.Groups["rvalueNoPotion"].Value
    nvalue = [double]$match.Groups["nvalue"].Value
    nvalueFly = [double]$match.Groups["nvalueFly"].Value
    nvalueRide = [double]$match.Groups["nvalueRide"].Value
    nvalueFlyRide = [double]$match.Groups["nvalueFlyRide"].Value
    nvalueNoPotion = [double]$match.Groups["nvalueNoPotion"].Value
    mvalue = [double]$match.Groups["mvalue"].Value
    mvalueFly = [double]$match.Groups["mvalueFly"].Value
    mvalueRide = [double]$match.Groups["mvalueRide"].Value
    mvalueFlyRide = [double]$match.Groups["mvalueFlyRide"].Value
    mvalueNoPotion = [double]$match.Groups["mvalueNoPotion"].Value
  })
}

if ($trackerItems.Count -lt 600) {
  throw "Tracker parse coverage dropped too low: $($trackerItems.Count) pet rows"
}

$trackerIndex = @{}
foreach ($item in $trackerItems) {
  $key = Normalize-Key $item.name
  if (-not $trackerIndex.ContainsKey($key)) {
    $trackerIndex[$key] = $item
  }
}

$legacy = Get-Content -LiteralPath (Resolve-RepoPath $LegacyCatalog) -Raw | ConvertFrom-Json
$benchmark = Get-Content -LiteralPath (Resolve-RepoPath $BenchmarkData) -Raw | ConvertFrom-Json
$manual = Get-Content -LiteralPath (Resolve-RepoPath $ManualMappings) -Raw | ConvertFrom-Json
$benchmarkIndex = @{}
foreach ($pet in $benchmark.pets) {
  $benchmarkIndex[$pet.slug] = $pet
}
$manualIndex = @{}
foreach ($pet in $manual.pets) {
  $manualIndex[$pet.slug] = $pet
}

$slugAliases = @{
  "phoenix-pet" = @("phoenix")
  "frost-fury-pet" = @("frost-fury")
  "mushroom-friend-pet" = @("mushroom-friend")
  "tortuga-de-la-isla-pet" = @("tortuga-de-la-isla")
  "princess-capuchin-monkey-pet" = @("princess-capuchin-monkey")
  "rosy-maple-moth-pet" = @("rosy-maple-moth")
  "karate-gorilla-pet" = @("karate-gorilla")
  "monkey-king-pet" = @("monkey-king")
  "vermilion-butterfly" = @("vermillion-butterfly")
  "kraken" = @("kroken", "kraken")
  "candicorn" = @("candicorn")
}

$overridePets = New-Object System.Collections.Generic.List[object]
$unmatched = New-Object System.Collections.Generic.List[string]
$benchmarkComparisons = New-Object System.Collections.Generic.List[object]
$trackerMatchedCount = 0
$manualResolvedCount = 0

foreach ($pet in $legacy.pets) {
  $trackerItem = $null
  $candidates = New-Object System.Collections.Generic.List[string]
  $candidates.Add((Normalize-Key $pet.name))
  $candidates.Add((Normalize-Key $pet.slug))
  if ($slugAliases.ContainsKey($pet.slug)) {
    foreach ($alias in $slugAliases[$pet.slug]) { $candidates.Add($alias) }
  }

  foreach ($candidate in ($candidates | Select-Object -Unique)) {
    if ($trackerIndex.ContainsKey($candidate)) {
      $trackerItem = $trackerIndex[$candidate]
      break
    }
  }

  if (-not $trackerItem) {
    if ($manualIndex.ContainsKey($pet.slug)) {
      $manualPet = $manualIndex[$pet.slug]
      $baseValue = [double]$manualPet.baseValue
      $manualSourceUrl = if ($manualPet.PSObject.Properties.Name -contains "sourceUrl") { $manualPet.sourceUrl } else { $null }
      $manualNotes = if ($manualPet.PSObject.Properties.Name -contains "notes") { $manualPet.notes } else { $null }
      $resolvedValues = if ($manualPet.resolution -eq "nonTradable") {
        [ordered]@{
          default = [ordered]@{ noPotion = 0; fly = 0; ride = 0; flyRide = 0 }
          neon = [ordered]@{ noPotion = 0; fly = 0; ride = 0; flyRide = 0 }
          mega = [ordered]@{ noPotion = 0; fly = 0; ride = 0; flyRide = 0 }
        }
      } else {
        [ordered]@{
          default = (Build-StageFromBase $baseValue 1)
          neon = (Build-StageFromBase $baseValue 4)
          mega = (Build-StageFromBase $baseValue 16)
        }
      }

      $overridePets.Add([pscustomobject]@{
        slug = $pet.slug
        name = $pet.name
        sourceUrl = $manualSourceUrl
        sourceType = "manual"
        resolution = $manualPet.resolution
        notes = $manualNotes
        values = $resolvedValues
      })
      $manualResolvedCount++
      continue
    }

    if (-not $benchmarkIndex.ContainsKey($pet.slug)) {
      $unmatched.Add($pet.name)
    }
    continue
  }

  if ($benchmarkIndex.ContainsKey($pet.slug)) {
    $sitePet = $benchmarkIndex[$pet.slug]
    $benchmarkComparisons.Add([pscustomobject]@{
      Name = $pet.name
      Slug = $pet.slug
      BenchmarkDefault = [double]$sitePet.values.default
      TrackerDefault = [double]$trackerItem.rvalueFlyRide
      BenchmarkNoPotion = [double]$(if ($null -ne $sitePet.values.noPotion) { $sitePet.values.noPotion } else { $sitePet.values.default })
      TrackerNoPotion = [double]$trackerItem.rvalueNoPotion
    })
    continue
  }

  $overridePets.Add([pscustomobject]@{
    slug = $pet.slug
    name = $pet.name
    sourceUrl = "https://adoptmevalues.app/values/$($pet.slug -replace '-pet$','')"
    sourceType = "tracker"
    values = [ordered]@{
      default = (Build-Stage $trackerItem "r")
      neon = (Build-Stage $trackerItem "n")
      mega = (Build-Stage $trackerItem "m")
    }
  })
  $trackerMatchedCount++
}

$overridePets = @($overridePets | Sort-Object name)

$payload = [ordered]@{
  updatedAt = (Get-Date -Format "yyyy-MM-dd")
  notes = "Bulk calculator override audit generated from the public Adopt Me Values values index source, with manual resolutions for edge-case pets. Benchmark pets remain on The Patch's shared benchmark layer."
  trackerMatchedCount = $trackerMatchedCount
  manualResolvedCount = $manualResolvedCount
  remainingUnmatchedCount = $unmatched.Count
  pets = @($overridePets)
}
$payload | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Resolve-RepoPath $OutJson)

$nonBenchmarkCount = @($legacy.pets | Where-Object { -not $benchmarkIndex.ContainsKey($_.slug) }).Count
$matchedCount = $overridePets.Count
$unmatchedCount = $unmatched.Count
$benchmarkDiffs = @($benchmarkComparisons | ForEach-Object {
  $tracker = if ($_.TrackerDefault -gt 0) { $_.TrackerDefault } else { 1 }
  [pscustomobject]@{
    Name = $_.Name
    TrackerDefault = $_.TrackerDefault
    BenchmarkDefault = $_.BenchmarkDefault
    DefaultDeltaPct = [math]::Round((($_.BenchmarkDefault - $_.TrackerDefault) / $tracker) * 100, 1)
    TrackerNoPotion = $_.TrackerNoPotion
    BenchmarkNoPotion = $_.BenchmarkNoPotion
  }
} | Sort-Object {[math]::Abs($_.DefaultDeltaPct)} -Descending)

$report = @()
$report += "# Calculator Audit Report"
$report += ""
$report += "- Date: $(Get-Date -Format 'yyyy-MM-dd')"
$report += "- Tracker pet rows parsed: $($trackerItems.Count)"
$report += "- Local calculator pets: $($legacy.pets.Count)"
$report += "- Non-benchmark local pets: $nonBenchmarkCount"
$report += "- Non-benchmark pets matched to tracker feed: $trackerMatchedCount"
$report += "- Non-benchmark pets manually resolved: $manualResolvedCount"
$report += "- Non-benchmark pets still unmatched: $unmatchedCount"
$report += ""
$report += "## Benchmark Divergence"
$report += ""
$report += "| Pet | Patch default | Tracker FR | Delta % | Patch no-pot | Tracker no-pot |"
$report += "| --- | ---: | ---: | ---: | ---: | ---: |"
foreach ($row in ($benchmarkDiffs | Select-Object -First 25)) {
  $report += "| $($row.Name) | $($row.BenchmarkDefault) | $($row.TrackerDefault) | $($row.DefaultDeltaPct)% | $($row.BenchmarkNoPotion) | $($row.TrackerNoPotion) |"
}
$report += ""
$report += "## Manual Edge-Case Resolutions"
$report += ""
if ($manualResolvedCount -eq 0) {
  $report += "No manual edge-case mappings were needed."
} else {
  foreach ($row in ($manual.pets | Sort-Object name)) {
    $report += "- $($row.name): $($row.resolution) ($($row.notes))"
  }
}
$report += ""
$report += "## Unmatched Local Pets"
$report += ""
if ($unmatchedCount -eq 0) {
  if ($manualResolvedCount -gt 0) {
    $report += "All non-benchmark local pets were resolved through either the tracker feed or documented manual mappings."
  } else {
    $report += "All non-benchmark local pets matched the tracker feed."
  }
} else {
  foreach ($name in ($unmatched | Sort-Object | Select-Object -First 200)) {
    $report += "- $name"
  }
}
$report | Set-Content -LiteralPath (Resolve-RepoPath $OutReport)

Write-Output ("tracker_rows={0} tracker_matched={1} manual_resolved={2} unmatched_non_benchmark={3}" -f $trackerItems.Count, $trackerMatchedCount, $manualResolvedCount, $unmatchedCount)
