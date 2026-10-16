param(
  [Parameter(Mandatory = $true)][string]$Url,
  [string]$LastMod = (Get-Date -Format 'yyyy-MM-dd'),
  [string]$ChangeFreq = 'weekly',
  [string]$Priority = '0.8'
)
$ErrorActionPreference = 'Stop'
if ($Url -notmatch '^https://thepatchgg\.github\.io/[^\s]+$') { throw 'Expected a Patch site URL.' }
$sitemapPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'sitemap.xml'
[xml]$sitemap = Get-Content -Raw -LiteralPath $sitemapPath
$ns = 'http://www.sitemaps.org/schemas/sitemap/0.9'
$entry = @($sitemap.urlset.url | Where-Object { $_.loc -eq $Url })
if ($entry.Count -gt 1) { throw 'Duplicate sitemap URL.' }
if ($entry.Count -eq 1) {
  $entry[0].lastmod = $LastMod
} else {
  $urlNode = $sitemap.CreateElement('url', $ns)
  foreach ($pair in @(@('loc', $Url), @('lastmod', $LastMod), @('changefreq', $ChangeFreq), @('priority', $Priority))) {
    $node = $sitemap.CreateElement($pair[0], $ns)
    $node.InnerText = $pair[1]
    [void]$urlNode.AppendChild($node)
  }
  [void]$sitemap.urlset.AppendChild($urlNode)
}
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Encoding = New-Object System.Text.UTF8Encoding($false)
$settings.Indent = $false
$writer = [System.Xml.XmlWriter]::Create($sitemapPath, $settings)
try { $sitemap.Save($writer) } finally { $writer.Dispose() }
Write-Output "Sitemap URL saved: $Url"
