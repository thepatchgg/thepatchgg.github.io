param(
  [string]$TrackerUrl = "https://www.adoptmevalues.app/values",
  [string]$SourceHtml = "data/adoptmevalues-values-page.html",
  [string]$OutJson = "data/adopt-me-calculator-overrides.json",
  [string]$OutReport = "data/adopt-me-calculator-audit-report.md",
  [string]$OutSummary = "VALUE_AUDIT_SUMMARY.md",
  [string]$StagingDir = "data/value-sync-staging",
  [switch]$AuditOnly,
  [switch]$UseCachedSource,
  [switch]$SkipQa
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

function Get-BenchmarkTableRows([string[]]$Lines) {
  $rows = New-Object System.Collections.Generic.List[string]
  $capture = $false

  foreach ($line in $Lines) {
    if ($line -eq "## Benchmark Divergence") {
      $capture = $true
      continue
    }

    if (-not $capture) {
      continue
    }

    if ([string]::IsNullOrWhiteSpace($line)) {
      if ($rows.Count -gt 0) { break }
      continue
    }

    if ($line -like "| *") {
      if ($line -like "| Pet *" -or $line -like "| ---*") {
        continue
      }

      $rows.Add($line)
    }
  }

  return @($rows)
}

$resolvedSourcePath = Resolve-RepoPath $SourceHtml
$resolvedOutJson = Resolve-RepoPath $OutJson
$resolvedOutReport = Resolve-RepoPath $OutReport
$resolvedOutSummary = Resolve-RepoPath $OutSummary

if ($AuditOnly) {
  $resolvedStagingDir = Resolve-RepoPath $StagingDir
  if (-not (Test-Path -LiteralPath $resolvedStagingDir)) {
    New-Item -ItemType Directory -Path $resolvedStagingDir | Out-Null
  }

  $resolvedOutJson = Join-Path $resolvedStagingDir "adopt-me-calculator-overrides.candidate.json"
  $resolvedOutReport = Join-Path $resolvedStagingDir "adopt-me-calculator-audit-report.candidate.md"
  $resolvedOutSummary = Join-Path $resolvedStagingDir "VALUE_AUDIT_SUMMARY.candidate.md"
}

$sourceStatus = "cached"
if (-not $UseCachedSource) {
  try {
    & (Join-Path $PSScriptRoot "refresh-adoptmevalues-source.ps1") -Url $TrackerUrl -OutPath $SourceHtml | Out-Null
    $sourceStatus = "fresh"
  } catch {
    if (-not (Test-Path -LiteralPath $resolvedSourcePath)) {
      throw
    }

    Write-Warning ("Falling back to cached tracker source because fetch failed: {0}" -f $_.Exception.Message)
    $sourceStatus = "cached fallback"
  }
} elseif (-not (Test-Path -LiteralPath $resolvedSourcePath)) {
  throw "Cached source HTML not found: $resolvedSourcePath"
}

$buildOutput = & (Join-Path $PSScriptRoot "build-calculator-overrides.ps1") -SourceHtml $resolvedSourcePath -OutJson $resolvedOutJson -OutReport $resolvedOutReport

$overridePayload = Get-Content -LiteralPath $resolvedOutJson -Raw | ConvertFrom-Json
$reportLines = Get-Content -LiteralPath $resolvedOutReport
$benchmarkRows = Get-BenchmarkTableRows -Lines $reportLines

$summary = @()
$summary += "# Value Audit Summary"
$summary += ""
$summary += "- Date: $(Get-Date -Format 'yyyy-MM-dd')"
$summary += "- Source refresh: $sourceStatus"
$summary += "- Mode: $(if ($AuditOnly) { 'audit-only' } else { 'production refresh' })"
$summary += "- Scope: Adopt Me trade calculator long-tail pet values"
$summary += "- Reference source: adoptmevalues.app values index"
$summary += "- Local calculator coverage: 714 pets"
$summary += "- Non-benchmark pets matched to public tracker feed: $($overridePayload.trackerMatchedCount)"
$summary += "- Non-benchmark pets manually resolved: $($overridePayload.manualResolvedCount)"
$summary += "- Non-benchmark pets still unmatched: $($overridePayload.remainingUnmatchedCount)"
$summary += ""
$summary += "## What Changed"
$summary += ""
$summary += "- The calculator override layer was refreshed from the latest available tracker source."
$summary += "- Tracker-backed lanes now update the broad long-tail value catalog without overwriting the editorial benchmark layer."
$summary += "- Manual edge-case mappings remain in place for pets that do not map cleanly to the public tracker feed."
$summary += "- The detailed calculator audit lives in `data/adopt-me-calculator-audit-report.md`."
$summary += ""
$summary += "## Benchmark Review Queue"
$summary += ""
if ($benchmarkRows.Count -eq 0) {
  $summary += "No benchmark divergence rows were produced in the latest audit."
} else {
  $summary += "These benchmark pets still deserve human review before any editorial benchmark change:"
  $summary += ""
  $summary += "| Pet | Patch default | Tracker FR | Delta % |"
  $summary += "| --- | ---: | ---: | ---: |"
  foreach ($row in ($benchmarkRows | Select-Object -First 8)) {
    $parts = $row.Trim('|').Split('|') | ForEach-Object { $_.Trim() }
    if ($parts.Count -ge 4) {
      $summary += "| $($parts[0]) | $($parts[1]) | $($parts[2]) | $($parts[3]) |"
    }
  }
}
$summary += ""
$summary += "## Recommendation"
$summary += ""
$summary += "- Do not auto-update benchmark pets from this workflow."
$summary += "- Cross-check benchmark and spotlight pets against a second market reference before changing any live value file."
$summary += "- If audit-only mode was used, review the candidate files in `data/value-sync-staging` before publishing."
$summary += "- Only publish calculator override changes after QA passes and the conflict queue looks acceptable."
$summary += "- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer."

$summary | Set-Content -LiteralPath $resolvedOutSummary

$qaSiteStatus = "skipped"
$qaReleaseStatus = "skipped"
if (-not $SkipQa) {
  & (Join-Path $PSScriptRoot "qa-site.ps1") | Out-Null
  & (Join-Path $PSScriptRoot "qa-release.ps1") | Out-Null
  $qaSiteStatus = "passed"
  $qaReleaseStatus = "passed"
}

Write-Output ("source_status={0} tracker_matched={1} manual_resolved={2} unmatched={3} qa_site={4} qa_release={5}" -f $sourceStatus, $overridePayload.trackerMatchedCount, $overridePayload.manualResolvedCount, $overridePayload.remainingUnmatchedCount, $qaSiteStatus, $qaReleaseStatus)
