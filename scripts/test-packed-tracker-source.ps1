$ErrorActionPreference = 'Stop'
$parserPath = Join-Path $PSScriptRoot 'read-packed-tracker-source.ps1'
$fixturePath = Join-Path ([IO.Path]::GetTempPath()) ('patch-tracker-test-' + [guid]::NewGuid().ToString('N') + '.html')
function Write-Fixture($Rows) {
  $tree = @('$', '$L1', $null, @{ packed = @{ rarities = @('legendary'); types = @('pets'); items = $Rows } })
  $record = '29:' + (ConvertTo-Json -InputObject $tree -Depth 8 -Compress)
  $frame = ConvertTo-Json -InputObject @(1, $record) -Depth 10 -Compress
  [IO.File]::WriteAllText($fixturePath, '<script>self.__next_f.push(' + $frame + ')</script>')
}
try {
  $row = @('1', 'Fixture Pet', 'images/test.png', 0, 0, 0, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
  Write-Fixture @(,$row)
  $pets = @(& $parserPath -SourceHtml $fixturePath)
  if ($pets.Count -ne 1 -or $pets[0].rvalueFlyRide -ne 4 -or $pets[0].rvalueNoPotion -ne 5 -or $pets[0].nvalueFlyRide -ne 9 -or $pets[0].mvalueNoPotion -ne 15) { throw 'Packed variant field mapping failed.' }
  $row[7] = -1
  Write-Fixture @(,$row)
  $rejected = $false
  try { & $parserPath -SourceHtml $fixturePath | Out-Null } catch { $rejected = $true }
  if (-not $rejected) { throw 'Negative tracker value was accepted.' }
  $row[7] = 1
  Write-Fixture @($row, $row)
  $rejected = $false
  try { & $parserPath -SourceHtml $fixturePath | Out-Null } catch { $rejected = $true }
  if (-not $rejected) { throw 'Duplicate tracker ID was accepted.' }
  Write-Fixture @(,@('1', 'Too short'))
  $rejected = $false
  try { & $parserPath -SourceHtml $fixturePath | Out-Null } catch { $rejected = $true }
  if (-not $rejected) { throw 'Malformed tracker row was accepted.' }
  Write-Output 'Packed tracker tests passed: variant order, negative values, duplicate IDs, malformed rows.'
} finally {
  if (Test-Path -LiteralPath $fixturePath) { Remove-Item -LiteralPath $fixturePath }
}
