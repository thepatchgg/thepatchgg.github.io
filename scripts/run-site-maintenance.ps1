param(
  [switch]$Push,
  [switch]$DryRun,
  [int]$MinTrackerRows = 700,
  [int]$MinTrackerMatched = 600,
  [int]$MaxChangedFiles = 900,
  [string]$CommitMessage = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$today = Get-Date -Format "yyyy-MM-dd"
$displayDate = Get-Date -Format "MMMM d, yyyy"

function Resolve-RepoPath([string]$Path) {
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }

  return Join-Path $repoRoot $Path.Replace("/", "\")
}

function Read-JsonFile([string]$Path) {
  $raw = Get-Content -LiteralPath (Resolve-RepoPath $Path) -Raw
  $raw = $raw.TrimStart([char]0xFEFF)
  return $raw | ConvertFrom-Json
}

function Guardrail-Fail([string]$Message) {
  throw "MAINTENANCE_GUARDRAIL_BLOCKED: $Message"
}

function Get-GitOutput([string[]]$Args) {
  Push-Location $repoRoot
  try {
    $output = & git @Args
    if ($LASTEXITCODE -ne 0) {
      throw "git $($Args -join ' ') failed with exit code $LASTEXITCODE"
    }
    return @($output)
  } finally {
    Pop-Location
  }
}

function Invoke-MaintenanceStep([string]$Name, [scriptblock]$Script) {
  Write-Output "==> $Name"
  & $Script
}

function Update-CalculatorFreshness {
  $path = Resolve-RepoPath "pet-value-calculator.html"
  $content = Get-Content -LiteralPath $path -Raw
  $updated = $content -replace 'Updated [A-Z][a-z]+ \d{1,2}, \d{4}', ("Updated {0}" -f $displayDate)
  if ($updated -ne $content) {
    Set-Content -LiteralPath $path -Value $updated -NoNewline
  }
}

function Update-SitemapLastMod([string]$RelativePath) {
  $path = Resolve-RepoPath "sitemap.xml"
  $content = Get-Content -LiteralPath $path -Raw
  $escapedPath = [regex]::Escape($RelativePath)
  $pattern = "(<loc>https://thepatchgg\.github\.io/$escapedPath</loc><lastmod>)([^<]+)(</lastmod>)"
  $updated = [regex]::Replace($content, $pattern, "`${1}$today`${3}")
  if ($updated -ne $content) {
    Set-Content -LiteralPath $path -Value $updated -NoNewline
  }
}

function Update-ChangelogEntry {
  $path = Resolve-RepoPath "changelog.html"
  $content = Get-Content -LiteralPath $path -Raw
  $heading = "<h3>$displayDate</h3>"

  if ($content.Contains($heading)) {
    return
  }

  $override = Read-JsonFile "data/adopt-me-calculator-overrides.json"
  $audit = Get-Content -LiteralPath (Resolve-RepoPath "data/adopt-me-calculator-audit-report.md") -Raw
  $benchmarkText = if ($audit -match "No benchmark divergence rows were produced") {
    "No benchmark divergence rows remain in the audit."
  } else {
    "Benchmark divergences remain in the review queue, so the automated publish was blocked."
  }

  $entry = @"
        <article class="card">
          <h3>$displayDate</h3>
          <p>Ran the automated Adopt Me maintenance refresh against the live tracker. The calculator now has $($override.trackerMatchedCount) tracker-backed long-tail pets, $($override.manualResolvedCount) manual edge cases, and $($override.remainingUnmatchedCount) unmatched local pets. $benchmarkText</p>
        </article>
"@

  $marker = '      <div class="shell stack">'
  $index = $content.IndexOf($marker)
  if ($index -lt 0) {
    Guardrail-Fail "Could not find changelog insertion point."
  }

  $insertAt = $index + $marker.Length
  $updated = $content.Insert($insertAt, "`r`n$entry")
  Set-Content -LiteralPath $path -Value $updated -NoNewline
}

Push-Location $repoRoot
try {
  if ($Push) {
    $initialStatus = @(git status --porcelain)
    if ($initialStatus.Count -gt 0) {
      Guardrail-Fail "Working tree must be clean before an unattended push."
    }
  }

  Invoke-MaintenanceStep "Refresh live tracker source" {
    & (Join-Path $PSScriptRoot "refresh-adoptmevalues-source.ps1") | Out-Host
  }

  Invoke-MaintenanceStep "Sync benchmark values" {
    & (Join-Path $PSScriptRoot "sync-benchmark-values.ps1") | Out-Host
  }

  Invoke-MaintenanceStep "Refresh calculator override/audit layer" {
    & (Join-Path $PSScriptRoot "refresh-pet-values.ps1") -SkipQa | Out-Host
  }

  Invoke-MaintenanceStep "Sync catalog rarity audit" {
    & (Join-Path $PSScriptRoot "sync-pet-catalog-rarity.ps1") | Out-Host
  }

  Invoke-MaintenanceStep "Regenerate pet pages and sitemap" {
    & (Join-Path $PSScriptRoot "generate-adopt-pet-pages.ps1") | Out-Host
  }

  Invoke-MaintenanceStep "Update public freshness markers" {
    Update-CalculatorFreshness
    Update-ChangelogEntry
    Update-SitemapLastMod -RelativePath "pet-value-calculator.html"
    Update-SitemapLastMod -RelativePath "changelog.html"
  }

  $summary = Get-Content -LiteralPath (Resolve-RepoPath "VALUE_AUDIT_SUMMARY.md") -Raw
  $audit = Get-Content -LiteralPath (Resolve-RepoPath "data/adopt-me-calculator-audit-report.md") -Raw
  $catalogAudit = Get-Content -LiteralPath (Resolve-RepoPath "data/adopt-me-pet-catalog-audit.md") -Raw
  $override = Read-JsonFile "data/adopt-me-calculator-overrides.json"
  $catalog = Read-JsonFile "data/adopt-me-pet-catalog.json"

  if ($summary -notmatch "Source refresh: fresh") {
    Guardrail-Fail "Tracker source was not fresh."
  }

  if ($audit -match "Tracker pet rows parsed: (\d+)") {
    if ([int]$matches[1] -lt $MinTrackerRows) {
      Guardrail-Fail "Tracker row coverage dropped to $($matches[1]); minimum is $MinTrackerRows."
    }
  } else {
    Guardrail-Fail "Calculator audit is missing tracker row coverage."
  }

  if ($audit -notmatch "Non-benchmark pets still unmatched: 0") {
    Guardrail-Fail "Calculator audit has unmatched pets."
  }

  if ($audit -notmatch "No benchmark divergence rows were produced") {
    Guardrail-Fail "Benchmark divergence rows remain after sync."
  }

  if ([int]$override.trackerMatchedCount -lt $MinTrackerMatched) {
    Guardrail-Fail "Tracker-backed calculator count dropped to $($override.trackerMatchedCount); minimum is $MinTrackerMatched."
  }

  if ([int]$override.remainingUnmatchedCount -ne 0) {
    Guardrail-Fail "Override payload still has unmatched pets: $($override.remainingUnmatchedCount)."
  }

  if ([int]$catalog.counts.review -ne 0) {
    Guardrail-Fail "Pet catalog has $($catalog.counts.review) entries marked for review."
  }

  if ($catalogAudit -notmatch "Entries still marked for review: 0") {
    Guardrail-Fail "Pet catalog audit has review entries."
  }

  $deletedFiles = @(git diff --name-status | Where-Object { $_ -match '^D\s+' })
  if ($deletedFiles.Count -gt 0) {
    Guardrail-Fail "Maintenance attempted to delete files: $($deletedFiles -join '; ')"
  }

  $changedFiles = @(git diff --name-only)
  if ($changedFiles.Count -gt $MaxChangedFiles) {
    Guardrail-Fail "Maintenance touched $($changedFiles.Count) files; maximum is $MaxChangedFiles."
  }

  Invoke-MaintenanceStep "Run site QA" {
    & (Join-Path $PSScriptRoot "qa-site.ps1") | Out-Host
  }

  Invoke-MaintenanceStep "Run release QA" {
    & (Join-Path $PSScriptRoot "qa-release.ps1") | Out-Host
  }

  $changedFiles = @(git diff --name-only)
  if ($changedFiles.Count -eq 0) {
    Write-Output "maintenance_result=no_changes"
    return
  }

  Write-Output ("maintenance_changed_files={0}" -f $changedFiles.Count)
  $changedFiles | ForEach-Object { Write-Output ("changed={0}" -f $_) }

  if ($DryRun -or -not $Push) {
    Write-Output "maintenance_result=changes_ready_not_pushed"
    return
  }

  Invoke-MaintenanceStep "Commit and push safe maintenance changes" {
    git add `
      VALUE_AUDIT_SUMMARY.md `
      changelog.html `
      pet-value-calculator.html `
      sitemap.xml `
      data/adoptmevalues-values-page.html `
      data/adopt-me-values.json `
      data/adopt-me-calculator-overrides.json `
      data/adopt-me-calculator-audit-report.md `
      data/adopt-me-pet-catalog.json `
      data/adopt-me-pet-catalog-audit.md `
      data/adopt-me-pet-pages.json `
      pets/

    if ($LASTEXITCODE -ne 0) {
      throw "git add failed"
    }

    if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
      $CommitMessage = "Automated Adopt Me maintenance refresh for $today"
    }

    git commit -m $CommitMessage
    if ($LASTEXITCODE -ne 0) {
      throw "git commit failed"
    }

    git push origin HEAD:main
    if ($LASTEXITCODE -ne 0) {
      throw "git push failed"
    }
  }

  Write-Output "maintenance_result=pushed"
} finally {
  Pop-Location
}
