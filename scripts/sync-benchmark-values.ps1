param(
  [string]$SourceHtml = "data/adoptmevalues-values-page.html",
  [string]$BenchmarkData = "data/adopt-me-values.json"
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
  $normalized = $normalized -replace "\\u0026", "and"
  $normalized = $normalized -replace "\(pet\)", ""
  $normalized = $normalized -replace "[^a-z0-9]+", "-"
  return $normalized.Trim("-")
}

function Round-Value([double]$Value) {
  return [math]::Round($Value, 2)
}

function Read-TrackerRows([string]$Path) {
  $raw = Get-Content -LiteralPath (Resolve-RepoPath $Path) -Raw
  $rowPattern = '\\\"id\\\":\\\"(?<id>\d+)\\\".*?\\\"name\\\":\\\"(?<name>.*?)\\\".*?\\\"rarity\\\":\\\"(?<rarity>.*?)\\\".*?\\\"type\\\":\\\"(?<type>.*?)\\\".*?\\\"rvalue\\\":(?<rvalue>[0-9.]+).*?\\\"rvalueFly\\\":(?<rvalueFly>[0-9.]+).*?\\\"rvalueRide\\\":(?<rvalueRide>[0-9.]+).*?\\\"rvalueFlyRide\\\":(?<rvalueFlyRide>[0-9.]+).*?\\\"rvalueNoPotion\\\":(?<rvalueNoPotion>[0-9.]+).*?\\\"nvalue\\\":(?<nvalue>[0-9.]+).*?\\\"nvalueFly\\\":(?<nvalueFly>[0-9.]+).*?\\\"nvalueRide\\\":(?<nvalueRide>[0-9.]+).*?\\\"nvalueFlyRide\\\":(?<nvalueFlyRide>[0-9.]+).*?\\\"nvalueNoPotion\\\":(?<nvalueNoPotion>[0-9.]+).*?\\\"mvalue\\\":(?<mvalue>[0-9.]+).*?\\\"mvalueFly\\\":(?<mvalueFly>[0-9.]+).*?\\\"mvalueRide\\\":(?<mvalueRide>[0-9.]+).*?\\\"mvalueFlyRide\\\":(?<mvalueFlyRide>[0-9.]+).*?\\\"mvalueNoPotion\\\":(?<mvalueNoPotion>[0-9.]+)'
  $matches = [regex]::Matches($raw, $rowPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  $rows = @{}

  foreach ($match in $matches) {
    if ($match.Groups["type"].Value -ne "pets") {
      continue
    }

    $row = [pscustomobject]@{
      name = ($match.Groups["name"].Value -replace '\\u0026', '&')
      rvalueFly = [double]$match.Groups["rvalueFly"].Value
      rvalueRide = [double]$match.Groups["rvalueRide"].Value
      rvalueFlyRide = [double]$match.Groups["rvalueFlyRide"].Value
      rvalueNoPotion = [double]$match.Groups["rvalueNoPotion"].Value
      nvalueFly = [double]$match.Groups["nvalueFly"].Value
      nvalueRide = [double]$match.Groups["nvalueRide"].Value
      nvalueFlyRide = [double]$match.Groups["nvalueFlyRide"].Value
      nvalueNoPotion = [double]$match.Groups["nvalueNoPotion"].Value
      mvalueFly = [double]$match.Groups["mvalueFly"].Value
      mvalueRide = [double]$match.Groups["mvalueRide"].Value
      mvalueFlyRide = [double]$match.Groups["mvalueFlyRide"].Value
      mvalueNoPotion = [double]$match.Groups["mvalueNoPotion"].Value
    }

    $key = Normalize-Key $row.name
    if (-not $rows.ContainsKey($key)) {
      $rows[$key] = $row
    }
  }

  if ($rows.Count -lt 600) {
    throw "Tracker parse coverage dropped too low: $($rows.Count) pet rows"
  }

  return $rows
}

$benchmarkPath = Resolve-RepoPath $BenchmarkData
$benchmark = Get-Content -LiteralPath $benchmarkPath -Raw | ConvertFrom-Json
$trackerRows = Read-TrackerRows -Path $SourceHtml

$aliasMap = @{
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

$updated = 0
$missing = New-Object System.Collections.Generic.List[string]
$today = Get-Date -Format "yyyy-MM-dd"

foreach ($pet in $benchmark.pets) {
  $tracker = $null
  $candidates = New-Object System.Collections.Generic.List[string]
  $candidates.Add((Normalize-Key $pet.name))
  $candidates.Add((Normalize-Key $pet.slug))
  if ($aliasMap.ContainsKey($pet.slug)) {
    foreach ($alias in $aliasMap[$pet.slug]) { $candidates.Add($alias) }
  }

  foreach ($candidate in ($candidates | Select-Object -Unique)) {
    if ($trackerRows.ContainsKey($candidate)) {
      $tracker = $trackerRows[$candidate]
      break
    }
  }

  if (-not $tracker) {
    $missing.Add($pet.name)
    continue
  }

  $pet.values.default = Round-Value $tracker.rvalueFlyRide
  $pet.values.fly = Round-Value $tracker.rvalueFly
  $pet.values.ride = Round-Value $tracker.rvalueRide
  $pet.values.noPotion = Round-Value $tracker.rvalueNoPotion
  $pet.values.neon = Round-Value $tracker.nvalueFlyRide
  $pet.values.neonFly = Round-Value $tracker.nvalueFly
  $pet.values.neonRide = Round-Value $tracker.nvalueRide
  $pet.values.neonNoPotion = Round-Value $tracker.nvalueNoPotion
  $pet.values.mega = Round-Value $tracker.mvalueFlyRide
  $pet.values.megaFly = Round-Value $tracker.mvalueFly
  $pet.values.megaRide = Round-Value $tracker.mvalueRide
  $pet.values.megaNoPotion = Round-Value $tracker.mvalueNoPotion
  $pet.notes = "Revalidated on $today against the live Adopt Me Values feed so this benchmark anchor matches the public tracker lanes used by the calculator."
  $updated++
}

if ($missing.Count -gt 0) {
  throw "Missing benchmark tracker rows: $($missing -join ', ')"
}

$benchmark.updatedAt = $today
$benchmark.methodology.summary = "The Patch benchmark values are aligned directly to the live Adopt Me Values feed so our benchmark pets match the same public lanes shown at adoptmevalues.app/values."
$benchmark.methodology.notes = @(
  "Benchmark pets mirror the live Adopt Me Values public feed as of $today.",
  "No Potion, Fly, Ride, Fly Ride, Neon, and Mega lanes are carried through from the same tracker source.",
  "Values can still move quickly, so recheck the source feed before making high-stakes trades."
)

$benchmark | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $benchmarkPath

Write-Output ("benchmark_updated={0} missing={1}" -f $updated, $missing.Count)
