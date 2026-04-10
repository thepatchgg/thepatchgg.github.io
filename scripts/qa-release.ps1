$repoRoot = Split-Path -Parent $PSScriptRoot

$issues = New-Object System.Collections.Generic.List[string]

$corePages = @(
  "index.html",
  "adopt-me.html",
  "pet-value-calculator.html",
  "neon-calculator.html",
  "egg-value-calculator.html",
  "inventory-planner.html",
  "market-movers.html",
  "about.html",
  "methodology.html",
  "editorial-policy.html",
  "parents.html",
  "privacy.html",
  "advertising.html",
  "articles/adopt-me-pet-value-list-2026.html",
  "articles/adopt-me-pet-encyclopedia.html",
  "pets/index.html"
)

$toolPages = @(
  "pet-value-calculator.html",
  "neon-calculator.html",
  "egg-value-calculator.html",
  "inventory-planner.html",
  "market-movers.html",
  "articles/adopt-me-pet-value-list-2026.html",
  "articles/adopt-me-pet-encyclopedia.html",
  "pets/index.html"
)

$newsletterPages = @(
  "index.html",
  "adopt-me.html"
)

$samplePetPages = @(
  "pets/bat-dragon.html",
  "pets/shadow-dragon.html",
  "pets/turtle.html"
)

function Resolve-PathInRepo {
  param([string]$RelativePath)

  return Join-Path $repoRoot $RelativePath.Replace("/", "\")
}

function Read-File {
  param([string]$RelativePath)

  $path = Resolve-PathInRepo $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    $issues.Add("Missing expected file: $RelativePath")
    return $null
  }

  return Get-Content -Raw -Path $path
}

function Assert-Pattern {
  param(
    [string]$Content,
    [string]$RelativePath,
    [string]$Pattern,
    [string]$Message
  )

  if ($null -eq $Content) {
    return
  }

  if ($Content -notmatch $Pattern) {
    $issues.Add("$Message in $RelativePath")
  }
}

function Assert-LocalAssetExists {
  param(
    [string]$RelativePath,
    [string]$Context
  )

  $cleanPath = $RelativePath.TrimStart('/').Replace("/", "\")
  $assetPath = Join-Path $repoRoot $cleanPath
  if (-not (Test-Path -LiteralPath $assetPath)) {
    $issues.Add("Missing asset for ${Context}: /$($cleanPath -replace '\\', '/')")
  }
}

foreach ($page in $corePages) {
  $content = Read-File $page
  if ($null -eq $content) {
    continue
  }

  Assert-Pattern $content $page "<title>.+</title>" "Missing <title>"
  Assert-Pattern $content $page "<meta name=`"description`" content=`"[^`"]+" "Missing meta description"
  Assert-Pattern $content $page "<link rel=`"canonical`" href=`"https://thepatchgg\.github\.io/[^`"]*`"" "Missing canonical"
  Assert-Pattern $content $page "<link rel=`"icon`" href=`"/favicon\.svg`"" "Missing favicon"
  Assert-Pattern $content $page "<link rel=`"manifest`" href=`"/site\.webmanifest`"" "Missing manifest"
  Assert-Pattern $content $page "<meta name=`"theme-color`" content=`"#08111f`"" "Missing theme-color"
  Assert-Pattern $content $page "googletagmanager\.com/gtag/js\?id=G-KXQR564341" "Missing GA loader"
}

foreach ($page in $toolPages) {
  $content = Read-File $page
  if ($null -eq $content) {
    continue
  }

  Assert-Pattern $content $page 'data-tool-name="' "Missing tool tracking marker"
  Assert-Pattern $content $page "/assets/js/adopt-analytics\.js" "Missing analytics helper include"
  Assert-Pattern $content $page 'href="/privacy\.html"' "Missing privacy link"
}

foreach ($page in $newsletterPages) {
  $content = Read-File $page
  if ($null -eq $content) {
    continue
  }

  Assert-Pattern $content $page 'class="newsletter-form"' "Missing newsletter form"
  Assert-Pattern $content $page 'data-newsletter-location="' "Missing newsletter location marker"
  Assert-Pattern $content $page "/newsletter\.js" "Missing newsletter script include"
  Assert-Pattern $content $page "/assets/js/adopt-analytics\.js" "Missing analytics helper include"
}

foreach ($page in $samplePetPages) {
  $content = Read-File $page
  if ($null -eq $content) {
    continue
  }

  Assert-Pattern $content $page "window\.THE_PATCH_PET_SLUG" "Missing pet slug bootstrap"
  Assert-Pattern $content $page "/assets/js/adopt-retention\.js" "Missing retention script include"
  Assert-Pattern $content $page "/assets/js/adopt-analytics\.js" "Missing analytics helper include"
  Assert-Pattern $content $page "/assets/js/adopt-pet-pages\.js" "Missing pet page script include"
  Assert-Pattern $content $page 'href="/privacy\.html"' "Missing privacy link"
}

$sitemap = Read-File "sitemap.xml"
Assert-Pattern $sitemap "sitemap.xml" "https://thepatchgg\.github\.io/privacy\.html" "Missing privacy URL in sitemap"
Assert-Pattern $sitemap "sitemap.xml" "https://thepatchgg\.github\.io/advertising\.html" "Missing advertising URL in sitemap"

$benchmarkData = Get-Content -Raw -Path (Resolve-PathInRepo "data/adopt-me-values.json") | ConvertFrom-Json
foreach ($pet in $benchmarkData.pets) {
  Assert-LocalAssetExists -RelativePath ("assets/pets/{0}.png" -f $pet.slug) -Context ("benchmark pet {0}" -f $pet.slug)
}

$catalogData = Get-Content -Raw -Path (Resolve-PathInRepo "data/adopt-me-pet-catalog.json") | ConvertFrom-Json
foreach ($entry in $catalogData.entries) {
  if ($entry.image -match '^/assets/') {
    Assert-LocalAssetExists -RelativePath $entry.image -Context ("catalog pet {0}" -f $entry.slug)
  }
}

$profileData = Get-Content -Raw -Path (Resolve-PathInRepo "data/adopt-me-benchmark-profiles.json") | ConvertFrom-Json
foreach ($profileName in $profileData.profiles.PSObject.Properties.Name) {
  $petPage = "pets/{0}.html" -f $profileName
  if (-not (Test-Path -LiteralPath (Resolve-PathInRepo $petPage))) {
    $issues.Add("Missing generated pet page: $petPage")
  }
}

$checklist = Read-File "PRE_MERGE_CHECKLIST.md"
Assert-Pattern $checklist "PRE_MERGE_CHECKLIST.md" "## Merge blockers" "Missing merge blocker section"
Assert-Pattern $checklist "PRE_MERGE_CHECKLIST.md" "## Analytics QA" "Missing analytics QA section"

$releaseNotes = Read-File "RELEASE_NOTES_DRAFT.md"
Assert-Pattern $releaseNotes "RELEASE_NOTES_DRAFT.md" "^# Release Notes Draft" "Missing release notes heading"

$auditReport = Read-File "data/adopt-me-calculator-audit-report.md"
Assert-Pattern $auditReport "data/adopt-me-calculator-audit-report.md" "^# Calculator Audit Report" "Missing calculator audit report heading"
Assert-Pattern $auditReport "data/adopt-me-calculator-audit-report.md" "Non-benchmark pets matched to tracker feed: 684" "Unexpected calculator audit coverage count"
Assert-Pattern $auditReport "data/adopt-me-calculator-audit-report.md" "Non-benchmark pets manually resolved: 12" "Unexpected calculator manual resolution count"
Assert-Pattern $auditReport "data/adopt-me-calculator-audit-report.md" "Non-benchmark pets still unmatched: 0" "Calculator audit still has unresolved pets"

$catalogAudit = Read-File "data/adopt-me-pet-catalog-audit.md"
Assert-Pattern $catalogAudit "data/adopt-me-pet-catalog-audit.md" "^# Pet Catalog Audit" "Missing pet catalog audit heading"
Assert-Pattern $catalogAudit "data/adopt-me-pet-catalog-audit.md" "Catalog entries: 725" "Unexpected pet catalog count"

$overrideData = Get-Content -Raw -Path (Resolve-PathInRepo "data/adopt-me-calculator-overrides.json") | ConvertFrom-Json
if (@($overrideData.pets).Count -lt 690) {
  $issues.Add("Calculator override coverage too low: $(@($overrideData.pets).Count) pets")
}
if ($overrideData.trackerMatchedCount -ne 684) {
  $issues.Add("Unexpected tracker-backed calculator count: $($overrideData.trackerMatchedCount)")
}
if ($overrideData.manualResolvedCount -ne 12) {
  $issues.Add("Unexpected manual calculator count: $($overrideData.manualResolvedCount)")
}
if ($overrideData.remainingUnmatchedCount -ne 0) {
  $issues.Add("Calculator still has unmatched pets: $($overrideData.remainingUnmatchedCount)")
}

$calculatorPage = Read-File "pet-value-calculator.html"
Assert-Pattern $calculatorPage "pet-value-calculator.html" 'id="tracker-audit-count">684<' "Calculator tracker audit count banner out of sync"
Assert-Pattern $calculatorPage "pet-value-calculator.html" 'id="manual-audit-count">12<' "Calculator manual audit count banner out of sync"
Assert-Pattern $calculatorPage "pet-value-calculator.html" 'id="audit-unmatched">0<' "Calculator unmatched count banner out of sync"

if ($catalogData.counts.total -ne 725) {
  $issues.Add("Unexpected pet catalog total: $($catalogData.counts.total)")
}
if ($catalogData.counts.verifiedRarity -lt 700) {
  $issues.Add("Pet catalog verified rarity coverage dropped too low: $($catalogData.counts.verifiedRarity)")
}
if ($catalogData.counts.review -gt 25) {
  $issues.Add("Too many pet catalog entries still marked for review: $($catalogData.counts.review)")
}

$scanFiles = Get-ChildItem -Path $repoRoot -Recurse -Include *.html,*.js,*.ps1,*.md,*.xml
$badEncodingPattern = ([char]0x00E2).ToString() + "|" + ([char]0x00C2).ToString()
foreach ($file in $scanFiles) {
  $content = Get-Content -Raw -Path $file.FullName
  $relativePath = $file.FullName.Substring($repoRoot.Length + 1) -replace "\\", "/"

  if ($relativePath -eq "data/adoptmevalues-values-page.html") {
    continue
  }

  if ($content -match $badEncodingPattern) {
    $issues.Add("Encoding artifact detected in $relativePath")
  }
}

$badPatterns = @(
  @{ Pattern = 'href="#"'; Message = "Dead anchor placeholder" },
  @{ Pattern = 'onsubmit="return false"'; Message = "Blocked inline submit handler" },
  @{ Pattern = "hello@\[(YOURDOMAIN)\]"; Message = "Placeholder contact address" },
  @{ Pattern = "TODO"; Message = "TODO marker left in release files" },
  @{ Pattern = "FIXME"; Message = "FIXME marker left in release files" }
)

foreach ($page in ($corePages + $samplePetPages)) {
  $content = Read-File $page
  if ($null -eq $content) {
    continue
  }

  foreach ($entry in $badPatterns) {
    if ($content -match $entry.Pattern) {
      $issues.Add("$($entry.Message) in $page")
    }
  }
}

$htmlFiles = Get-ChildItem -Path $repoRoot -Recurse -Filter *.html
foreach ($file in $htmlFiles) {
  $content = Get-Content -Raw -Path $file.FullName
  $relativePath = $file.FullName.Substring($repoRoot.Length + 1) -replace "\\", "/"

  if ($content -notmatch "/assets/js/patch-ribbon\.js") {
    $issues.Add("Menu ribbon normalizer missing in $relativePath")
  }
}

if ($issues.Count -gt 0) {
  $issues | Sort-Object -Unique | ForEach-Object { Write-Output $_ }
  exit 1
}

Write-Output ("Release QA passed for {0} core pages, {1} tool pages, and {2} sample pet pages." -f $corePages.Count, $toolPages.Count, $samplePetPages.Count)
