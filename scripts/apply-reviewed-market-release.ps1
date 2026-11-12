$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$today = '2026-11-12'
function Read-Data($name) { Get-Content (Join-Path $root "data/$name") -Raw | ConvertFrom-Json }
function Write-Data($name, $payload) { $payload | ConvertTo-Json -Depth 16 | Set-Content (Join-Path $root "data/$name") -Encoding utf8 }
function Key($name) { (($name.ToLowerInvariant() -replace '&amp;', 'and' -replace '\(pet\)', '' -replace '[^a-z0-9]+', '-').Trim('-')) }
$primary = @(& (Join-Path $PSScriptRoot 'read-packed-tracker-source.ps1') -SourceHtml (Join-Path $root 'data/adoptmevalues-values-page.html'))
$secondary = Read-Data 'market-secondary-review-20261112.json'
$benchmark = Read-Data 'adopt-me-values.json'
$candidate = Read-Data 'value-sync-staging/adopt-me-calculator-overrides.candidate.json'
$catalog = Read-Data 'adopt-me-pet-catalog.json'
$pages = Read-Data 'adopt-me-pet-pages.json'
$reviewed = @(); $deferred = @(); $priced = @(); $pending = @()
foreach ($pet in $benchmark.pets) {
  $key = Key $pet.name
  $source = $primary | Where-Object { (Key $_.name) -eq $key } | Select-Object -First 1
  $evidence = @($secondary.evidence | Where-Object { ($_.url -split '\?')[0] -eq "https://elvebredd.com/pets/$key" })
  $match = $evidence | Where-Object { ($_.variant -eq 'noPotion' -and $_.value -eq $source.rvalueNoPotion) -or ($_.variant -eq 'flyRide' -and $_.value -eq $source.rvalueFlyRide) } | Select-Object -First 1
  if (-not $source -or -not $match) {
    $deferred += [pscustomobject]@{slug=$pet.slug; reason=$(if($evidence.Count) {'Sources disagree'} else {'Second public reference unavailable'}); retainedReviewDate=$(if($pet.PSObject.Properties['reviewedAt']){$pet.reviewedAt}else{$null})}
    continue
  }
  $before = $pet.values.default
  foreach ($stage in @(@{target='';prefix='r'}, @{target='neon';prefix='n'}, @{target='mega';prefix='m'})) {
    foreach ($lane in @(@{target='default';source='FlyRide'},@{target='fly';source='Fly'},@{target='ride';source='Ride'},@{target='noPotion';source='NoPotion'})) {
      $target = if($stage.target) { if($lane.target -eq 'default'){$stage.target}else{$stage.target + $lane.target.Substring(0,1).ToUpperInvariant() + $lane.target.Substring(1)} } else {$lane.target}
      $pet.values.$target = [math]::Round($source.($stage.prefix+'value'+$lane.source),2)
    }
  }
  $pet | Add-Member -Force NoteProperty reviewedAt $today
  $pet.notes = "Reviewed November 12, 2026 using Adopt Me Values; the $($match.variant) reference matches Elvebredd. Other variant lanes follow Adopt Me Values. Values can change."
  $reviewed += [pscustomobject]@{slug=$pet.slug;before=$before;after=$pet.values.default;variant=$match.variant;primary=$match.value;secondary=$match.value;secondaryUrl=$match.url}
}
$benchmark.updatedAt=$today
$benchmark.methodology.notes = @("$($reviewed.Count) benchmark anchors were reviewed on November 12, 2026. $($deferred.Count) anchors retain their earlier dated values because sources disagree or an independent check was unavailable.", 'Reviewed pets use Adopt Me Values variant lanes. The independent check matches the same Fly Ride or No Potion variant.', 'Values can move quickly. New pets stay pending where sources materially disagree.')
Write-Data 'adopt-me-values.json' $benchmark
foreach ($pet in (@($pages.pets | Where-Object {$_.source -eq 'official-pending'}) + @([pscustomobject]@{slug='haetyphoon';name='Haetyphoon'},[pscustomobject]@{slug='blue-cat';name='Blue Cat'},[pscustomobject]@{slug='pink-dog';name='Pink Dog'}))) {
  $key = Key $pet.name
  $source = $primary | Where-Object {(Key $_.name) -eq $key} | Select-Object -First 1
  $match = $secondary.evidence | Where-Object {$_.url -eq "https://elvebredd.com/pets/$key" -and $_.variant -eq 'noPotion' -and $_.value -eq $source.rvalueNoPotion} | Select-Object -First 1
  if(-not $match) { $pending += [pscustomobject]@{slug=$pet.slug;reason='Sources disagree';primaryNoPotion=$source.rvalueNoPotion;secondaryNoPotion=@($secondary.evidence | Where-Object {$_.url -eq "https://elvebredd.com/pets/$key"}).value}; continue }
  if(@($candidate.pets | Where-Object {$_.slug -eq $pet.slug}).Count) { $priced += [pscustomobject]@{slug=$pet.slug;noPotion=$source.rvalueNoPotion;secondaryUrl=$match.url}; continue }
  $entry = $catalog.entries | Where-Object {$_.slug -eq $pet.slug} | Select-Object -First 1
  $matrix = [ordered]@{}
  foreach($stage in @(@{name='default';prefix='r'},@{name='neon';prefix='n'},@{name='mega';prefix='m'})) {
    $lanes=[ordered]@{}
    foreach($lane in @('noPotion','fly','ride','flyRide')) { $sourceLane=$lane.Substring(0,1).ToUpperInvariant()+$lane.Substring(1); $lanes[$lane]=[math]::Round($source.($stage.prefix+'value'+$sourceLane),2) }
    $matrix[$stage.name]=$lanes
  }
  $candidate.pets += [pscustomobject]@{slug=$pet.slug;name=$pet.name;rarity=$entry.rarity;image=$entry.image;sourceUrl="https://www.adoptmevalues.app/values/$key";sourceType='tracker';values=$matrix}
  $candidate.trackerMatchedCount++
  $priced += [pscustomobject]@{slug=$pet.slug;noPotion=$source.rvalueNoPotion;secondaryUrl=$match.url}
}
$candidate.updatedAt=$today
$candidate.pets=@($candidate.pets | Sort-Object slug)
Write-Data 'adopt-me-calculator-overrides.json' $candidate
Write-Data 'market-release-review-20261112.json' ([ordered]@{reviewedAt=$today;primarySource='https://www.adoptmevalues.app/values';sourceStatus='fresh';benchmarkReviewed=$reviewed;benchmarkDeferred=$deferred;newlyPriced=$priced;pending=$pending;trackerMatched=$candidate.trackerMatchedCount;manualResolved=$candidate.manualResolvedCount;unmatched=$candidate.remainingUnmatchedCount})
"benchmarks_reviewed=$($reviewed.Count) deferred=$($deferred.Count) tracker=$($candidate.trackerMatchedCount) manual=$($candidate.manualResolvedCount) newly_priced=$($priced.Count) pending=$($pending.Count)"
