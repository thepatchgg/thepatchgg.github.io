param(
  [string]$SourceHtml = "data/adoptmevalues-values-page.html",
  [string]$CatalogJson = "data/adopt-me-pet-catalog.json",
  [string]$BenchmarkData = "data/adopt-me-values.json",
  [string]$OutReport = "data/adopt-me-pet-catalog-audit.md"
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

function Convert-Rarity([string]$Rarity) {
  switch -Regex ($Rarity.Trim().ToLowerInvariant()) {
    "^event$" { return "event" }
    "^common$" { return "c" }
    "^uncommon$" { return "u" }
    "^rare$" { return "r" }
    "^ultra[- ]rare$" { return "ur" }
    "^legendary$" { return "l" }
    default { return "review" }
  }
}

$sourcePath = Resolve-RepoPath $SourceHtml
$catalogPath = Resolve-RepoPath $CatalogJson
$benchmarkPath = Resolve-RepoPath $BenchmarkData
$reportPath = Resolve-RepoPath $OutReport

if (-not (Test-Path -LiteralPath $sourcePath)) {
  throw "Source HTML not found: $SourceHtml"
}

if (-not (Test-Path -LiteralPath $catalogPath)) {
  throw "Catalog JSON not found: $CatalogJson"
}

$raw = Get-Content -LiteralPath $sourcePath -Raw
$rowPattern = '\\\"id\\\":\\\"(?<id>\d+)\\\".*?\\\"name\\\":\\\"(?<name>.*?)\\\".*?\\\"rarity\\\":\\\"(?<rarity>.*?)\\\".*?\\\"type\\\":\\\"(?<type>.*?)\\\"'
$matches = [regex]::Matches($raw, $rowPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

$trackerIndex = @{}
foreach ($match in $matches) {
  if ($match.Groups["type"].Value -ne "pets") {
    continue
  }

  $name = ($match.Groups["name"].Value -replace '\\u0026', '&')
  $key = Normalize-Key $name
  if (-not $trackerIndex.ContainsKey($key)) {
    $trackerIndex[$key] = [pscustomobject]@{
      name = $name
      rarity = Convert-Rarity $match.Groups["rarity"].Value
      trackerRarity = $match.Groups["rarity"].Value
    }
  }
}

if ($trackerIndex.Count -lt 650) {
  throw "Tracker rarity parse coverage dropped too low: $($trackerIndex.Count) pet rows"
}

$benchmark = Get-Content -LiteralPath $benchmarkPath -Raw | ConvertFrom-Json
$benchmarkIndex = @{}
foreach ($pet in $benchmark.pets) {
  $benchmarkIndex[$pet.slug] = $pet.rarity
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
  "malayan-tapir" = @("malaysian-tapir", "malayan-tapir")
  "mole-pet" = @("mole", "mole-pet")
  "praying-mantis-pet" = @("praying-mantis", "praying-mantis-pet")
  "weevil-pet" = @("weevil", "weevil-pet")
  "scoob" = @("scoob")
}

$manualRarity = @{
  "burtaur" = "c"
  "chocolate-guinea-pig" = "ur"
  "dark-choco-bunny" = "l"
  "dylan" = "u"
  "mfr-sandwich" = "c"
  "milk-choco-bunny" = "r"
  "pet-rock" = "u"
  "pistachio" = "u"
  "practice-dog" = "c"
  "pumpkin-pet" = "event"
  "red-guinea-pig" = "l"
  "river" = "u"
  "scoob" = "event"
  "white-choco-bunny" = "ur"
}

$catalog = Get-Content -LiteralPath $catalogPath -Raw | ConvertFrom-Json
$updatedEntries = New-Object System.Collections.Generic.List[object]
$matchedCount = 0
$reviewCount = 0
$unmatched = New-Object System.Collections.Generic.List[string]

foreach ($entry in $catalog.entries) {
  $candidateKeys = New-Object System.Collections.Generic.List[string]
  $candidateKeys.Add((Normalize-Key $entry.name))
  $candidateKeys.Add((Normalize-Key $entry.slug))
  if ($slugAliases.ContainsKey($entry.slug)) {
    foreach ($alias in $slugAliases[$entry.slug]) {
      $candidateKeys.Add($alias)
    }
  }

  $rarity = $entry.rarity
  $matched = $null

  foreach ($candidate in ($candidateKeys | Select-Object -Unique)) {
    if ($trackerIndex.ContainsKey($candidate)) {
      $matched = $trackerIndex[$candidate]
      break
    }
  }

  if ($matched) {
    $rarity = $matched.rarity
    $matchedCount++
  } elseif ($manualRarity.ContainsKey($entry.slug)) {
    $rarity = $manualRarity[$entry.slug]
    $matchedCount++
  } elseif ($benchmarkIndex.ContainsKey($entry.slug)) {
    $rarity = Convert-Rarity $benchmarkIndex[$entry.slug]
    $matchedCount++
  } else {
    $rarity = "review"
    $reviewCount++
    $unmatched.Add($entry.name)
  }

  $updatedEntries.Add([ordered]@{
    slug = $entry.slug
    name = $entry.name
    rarity = $rarity
    image = $entry.image
    benchmark = [bool]$entry.benchmark
  })
}

$entryArray = [object[]]$updatedEntries.ToArray()
$totalCount = $entryArray.Count
$verifiedCount = @($entryArray | Where-Object { $_.rarity -ne "review" }).Count
$reviewTotal = @($entryArray | Where-Object { $_.rarity -eq "review" }).Count
$benchmarkCount = @($entryArray | Where-Object { $_.benchmark }).Count

$counts = [pscustomobject]@{
  total = $totalCount
  verifiedRarity = $verifiedCount
  review = $reviewTotal
  benchmark = $benchmarkCount
}

$payload = [ordered]@{
  updatedAt = (Get-Date -Format "yyyy-MM-dd")
  entries = $entryArray
  counts = $counts
}

$payload | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $catalogPath

$report = @()
$report += "# Pet Catalog Audit"
$report += ""
$report += "- Date: $(Get-Date -Format 'yyyy-MM-dd')"
$report += "- Tracker pet rows parsed: $($trackerIndex.Count)"
$report += "- Catalog entries: $($counts.total)"
$report += "- Entries with verified rarity: $($counts.verifiedRarity)"
$report += "- Entries still marked for review: $($counts.review)"
$report += ""
$report += "## Notes"
$report += ""
$report += "- Rarity labels were synced from the cached public Adopt Me Values pet index where possible."
$report += "- Benchmark pets fall back to the shared Patch benchmark dataset if the tracker alias does not match directly."
$report += ""
$report += "## Remaining Review Entries"
$report += ""
if ($unmatched.Count -eq 0) {
  $report += "All catalog entries matched either the cached tracker dataset or the benchmark fallback."
} else {
  foreach ($name in ($unmatched | Sort-Object)) {
    $report += "- $name"
  }
}

$report | Set-Content -LiteralPath $reportPath

Write-Output ("catalog_total={0} verified_rarity={1} review={2}" -f $counts.total, $counts.verifiedRarity, $counts.review)
