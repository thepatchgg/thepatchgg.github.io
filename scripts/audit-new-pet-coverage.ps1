param(
  [Parameter(Mandatory = $true)]
  [string[]]$PetNames,
  [string]$OutReport = "data/new-pet-coverage-audit.md"
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

function Find-BySlugOrName($Collection, [string]$Slug, [string]$Name) {
  foreach ($item in $Collection) {
    $itemSlug = if ($item.PSObject.Properties["slug"]) { [string]$item.slug } else { "" }
    $itemName = if ($item.PSObject.Properties["name"]) { [string]$item.name } else { "" }
    if ($itemSlug -eq $Slug -or $itemName -eq $Name) {
      return $item
    }
  }
  return $null
}

function Get-CheckMark([bool]$Value) {
  if ($Value) { return "Yes" }
  return "No"
}

$catalogPath = Resolve-RepoPath "data/adopt-me-pet-catalog.json"
$benchmarkPath = Resolve-RepoPath "data/adopt-me-values.json"
$legacyPath = Resolve-RepoPath "data/adopt-me-calculator-values.json"
$overridesPath = Resolve-RepoPath "data/adopt-me-calculator-overrides.json"
$petPagesPath = Resolve-RepoPath "data/adopt-me-pet-pages.json"
$indexPath = Resolve-RepoPath "index.html"
$hubPath = Resolve-RepoPath "adopt-me.html"
$articlesDir = Resolve-RepoPath "articles"
$petsDir = Resolve-RepoPath "pets"
$assetsDir = Resolve-RepoPath "assets/pets"
$reportPath = Resolve-RepoPath $OutReport

$catalog = Get-Content -Raw -LiteralPath $catalogPath | ConvertFrom-Json
$benchmark = Get-Content -Raw -LiteralPath $benchmarkPath | ConvertFrom-Json
$legacy = Get-Content -Raw -LiteralPath $legacyPath | ConvertFrom-Json
$overrides = Get-Content -Raw -LiteralPath $overridesPath | ConvertFrom-Json
$petPages = Get-Content -Raw -LiteralPath $petPagesPath | ConvertFrom-Json

$indexContent = Get-Content -Raw -LiteralPath $indexPath
$hubContent = Get-Content -Raw -LiteralPath $hubPath
$articleFiles = Get-ChildItem -LiteralPath $articlesDir -Filter *.html
$articleHits = @{}

$rows = New-Object System.Collections.Generic.List[object]
$report = New-Object System.Collections.Generic.List[string]

foreach ($petName in $PetNames) {
  $slug = Normalize-Key $petName

  $catalogEntry = Find-BySlugOrName $catalog.entries $slug $petName
  $legacyEntry = Find-BySlugOrName $legacy.pets $slug $petName
  $benchmarkEntry = Find-BySlugOrName $benchmark.pets $slug $petName
  $overrideEntry = Find-BySlugOrName $overrides.pets $slug $petName
  $pageEntry = Find-BySlugOrName $petPages.pets $slug $petName

  $petPagePath = Join-Path $petsDir "$slug.html"
  $petPageExists = Test-Path -LiteralPath $petPagePath

  $imageExists = $false
  foreach ($extension in @("png", "webp", "jpg", "jpeg", "svg")) {
    if (Test-Path -LiteralPath (Join-Path $assetsDir "$slug.$extension")) {
      $imageExists = $true
      break
    }
  }

  $articleMatches = @()
  foreach ($file in $articleFiles) {
    $content = Get-Content -Raw -LiteralPath $file.FullName
    if ($content -match [regex]::Escape($petName)) {
      $articleMatches += $file.Name
    }
  }

  $homepageMention = $indexContent -match [regex]::Escape($petName)
  $hubMention = $hubContent -match [regex]::Escape($petName)

  $rows.Add([pscustomobject]@{
    Pet = $petName
    Slug = $slug
    ArticleCoverage = $articleMatches.Count -gt 0
    Homepage = $homepageMention
    GuideHub = $hubMention
    Catalog = $null -ne $catalogEntry
    LegacyCalculator = $null -ne $legacyEntry
    BenchmarkLayer = $null -ne $benchmarkEntry
    OverrideLayer = $null -ne $overrideEntry
    PetPageData = $null -ne $pageEntry
    PetPage = $petPageExists
    ImageAsset = $imageExists
    Articles = ($articleMatches -join ", ")
  }) | Out-Null
}

$report.Add("# New Pet Coverage Audit")
$report.Add("")
$report.Add("- Date: $(Get-Date -Format 'yyyy-MM-dd')")
$report.Add("- Pets checked: $($PetNames -join ', ')")
$report.Add("")
$report.Add("| Pet | Article | Home | Hub | Catalog | Legacy Calc | Benchmark | Override | Pet Page Data | Pet Page | Image |")
$report.Add("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")

foreach ($row in $rows) {
  $report.Add("| $($row.Pet) | $(Get-CheckMark $row.ArticleCoverage) | $(Get-CheckMark $row.Homepage) | $(Get-CheckMark $row.GuideHub) | $(Get-CheckMark $row.Catalog) | $(Get-CheckMark $row.LegacyCalculator) | $(Get-CheckMark $row.BenchmarkLayer) | $(Get-CheckMark $row.OverrideLayer) | $(Get-CheckMark $row.PetPageData) | $(Get-CheckMark $row.PetPage) | $(Get-CheckMark $row.ImageAsset) |")
}

$report.Add("")
$report.Add("## Notes")
$report.Add("")

foreach ($row in $rows) {
  $missing = @()
  foreach ($pair in @(
    @{ Label = "article coverage"; Value = $row.ArticleCoverage },
    @{ Label = "homepage promotion"; Value = $row.Homepage },
    @{ Label = "guide hub promotion"; Value = $row.GuideHub },
    @{ Label = "pet catalog"; Value = $row.Catalog },
    @{ Label = "legacy calculator dataset"; Value = $row.LegacyCalculator },
    @{ Label = "benchmark layer"; Value = $row.BenchmarkLayer },
    @{ Label = "override layer"; Value = $row.OverrideLayer },
    @{ Label = "pet-page dataset"; Value = $row.PetPageData },
    @{ Label = "generated pet page"; Value = $row.PetPage },
    @{ Label = "local image asset"; Value = $row.ImageAsset }
  )) {
    if (-not $pair.Value) {
      $missing += $pair.Label
    }
  }

  $articleNote = if ([string]::IsNullOrWhiteSpace($row.Articles)) { "none" } else { $row.Articles }
  $report.Add("- **$($row.Pet)**")
  $report.Add("  - Article hits: $articleNote")
  if ($missing.Count -eq 0) {
    $report.Add("  - Result: fully covered across the audited layers.")
  } else {
    $report.Add("  - Missing: $($missing -join ', ')")
  }
}

$report | Set-Content -LiteralPath $reportPath

$rows | Format-Table -AutoSize
Write-Output ""
Write-Output "report=$reportPath"
