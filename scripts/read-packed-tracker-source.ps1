param([Parameter(Mandatory = $true)][string]$SourceHtml)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$raw = Get-Content -LiteralPath $SourceHtml -Raw
$packed = $null
# Decode JSON payloads only; never execute scripts from the remote page.
foreach ($scriptMatch in [regex]::Matches($raw, '<script>self\.__next_f\.push\((.*?)\)</script>', 'Singleline')) {
  try { $frame = ConvertFrom-Json -InputObject $scriptMatch.Groups[1].Value } catch { continue }
  if ($frame.Count -lt 2 -or $frame[1] -isnot [string] -or $frame[1] -notmatch '"packed"') { continue }
  foreach ($record in ($frame[1] -split "`n")) {
    if ($record -notmatch '^\w+:(\[.*)$' -or $record -notmatch '"packed"') { continue }
    try { $tree = ConvertFrom-Json -InputObject $record.Substring($record.IndexOf(':') + 1) } catch { continue }
    if ($tree.Count -ge 4 -and $tree[3].PSObject.Properties['packed']) { $packed = $tree[3].packed; break }
  }
  if ($null -ne $packed) { break }
}
if ($null -eq $packed) { throw 'No supported packed tracker payload was found.' }
foreach ($field in @('items', 'types', 'rarities')) {
  if (-not $packed.PSObject.Properties[$field]) { throw "Missing packed tracker field: $field" }
}
$valueFields = @('rvalue', 'rvalueFly', 'rvalueRide', 'rvalueFlyRide', 'rvalueNoPotion', 'nvalue', 'nvalueFly', 'nvalueRide', 'nvalueFlyRide', 'nvalueNoPotion', 'mvalue', 'mvalueFly', 'mvalueRide', 'mvalueFlyRide', 'mvalueNoPotion')
$seen = @{}
foreach ($row in $packed.items) {
  if ($row.Count -ne 22) { throw "Unsupported packed row length: $($row.Count)" }
  if ([int]$row[4] -lt 0 -or [int]$row[4] -ge $packed.types.Count) { throw 'Invalid tracker type index.' }
  if ($packed.types[[int]$row[4]] -ne 'pets') { continue }
  if ([int]$row[3] -lt 0 -or [int]$row[3] -ge $packed.rarities.Count) { throw 'Invalid tracker rarity index.' }
  if ([string]::IsNullOrWhiteSpace($row[1]) -or $seen.ContainsKey([string]$row[0])) { throw 'Empty name or duplicate tracker pet ID.' }
  $seen[[string]$row[0]] = $true
  $item = [ordered]@{ id = [string]$row[0]; name = [string]$row[1]; rarity = $packed.rarities[[int]$row[3]]; type = 'pets' }
  # Matches the source's unpackPets decoder, reviewed October 16, 2026.
  # https://www.adoptmevalues.app/_next/static/chunks/dddc39afc23e4969.js
  for ($index = 0; $index -lt $valueFields.Count; $index++) {
    $number = $row[$index + 7]
    if ($null -eq $number -or $number -is [string] -or $number -is [bool] -or [double]$number -lt 0 -or [double]::IsNaN([double]$number) -or [double]::IsInfinity([double]$number)) { throw "Invalid tracker value for $($row[1])." }
    $item[$valueFields[$index]] = [double]$number
  }
  [pscustomobject]$item
}
