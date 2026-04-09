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

$checklist = Read-File "PRE_MERGE_CHECKLIST.md"
Assert-Pattern $checklist "PRE_MERGE_CHECKLIST.md" "## Merge blockers" "Missing merge blocker section"
Assert-Pattern $checklist "PRE_MERGE_CHECKLIST.md" "## Analytics QA" "Missing analytics QA section"

$releaseNotes = Read-File "RELEASE_NOTES_DRAFT.md"
Assert-Pattern $releaseNotes "RELEASE_NOTES_DRAFT.md" "^# Release Notes Draft" "Missing release notes heading"

$scanFiles = Get-ChildItem -Path $repoRoot -Recurse -Include *.html,*.js,*.ps1,*.md,*.xml
$badEncodingPattern = ([char]0x00E2).ToString() + "|" + ([char]0x00C2).ToString()
foreach ($file in $scanFiles) {
  $content = Get-Content -Raw -Path $file.FullName
  $relativePath = $file.FullName.Substring($repoRoot.Length + 1) -replace "\\", "/"

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

if ($issues.Count -gt 0) {
  $issues | Sort-Object -Unique | ForEach-Object { Write-Output $_ }
  exit 1
}

Write-Output ("Release QA passed for {0} core pages, {1} tool pages, and {2} sample pet pages." -f $corePages.Count, $toolPages.Count, $samplePetPages.Count)
