$repoRoot = Split-Path -Parent $PSScriptRoot
$valuesPath = Join-Path $repoRoot "data\\adopt-me-values.json"
$profilesPath = Join-Path $repoRoot "data\\adopt-me-benchmark-profiles.json"
$petsDir = Join-Path $repoRoot "pets"

$values = Get-Content -Raw -Path $valuesPath | ConvertFrom-Json
$profiles = (Get-Content -Raw -Path $profilesPath | ConvertFrom-Json).profiles

$toneClass = @{
  "Elite" = "tone-elite"
  "Very High" = "tone-very-high"
  "High" = "tone-high"
  "Medium" = "tone-medium"
  "Low" = "tone-low"
  "Rising" = "tone-rising"
  "Steady" = "tone-steady"
  "Falling" = "tone-falling"
}

$variantLabels = @{
  "default" = "Default"
  "noPotion" = "No Potion"
  "neon" = "Neon"
  "neonNoPotion" = "Neon No Potion"
  "mega" = "Mega Neon"
  "megaNoPotion" = "Mega No Potion"
}

function Format-Value {
  param([double]$Value)

  if ($Value -ge 1000) {
    if (($Value % 1000) -eq 0) {
      return "{0}K" -f [int]($Value / 1000)
    }

    return "{0:0.#}K" -f ($Value / 1000)
  }

  if ($Value -eq [math]::Floor($Value)) {
    return [string][int]$Value
  }

  if ($Value -lt 10) {
    return ("{0:0.00}" -f $Value).TrimEnd("0").TrimEnd(".")
  }

  return ("{0:0.0}" -f $Value).TrimEnd("0").TrimEnd(".")
}

if (-not (Test-Path -LiteralPath $petsDir)) {
  New-Item -ItemType Directory -Path $petsDir | Out-Null
}

foreach ($pet in $values.pets) {
  $profile = $profiles.PSObject.Properties[$pet.slug].Value
  if (-not $profile) {
    continue
  }

  $relatedCards = foreach ($relatedSlug in $profile.compareWith) {
    $related = $values.pets | Where-Object { $_.slug -eq $relatedSlug } | Select-Object -First 1
    if (-not $related) { continue }

    $relatedDemandTone = $toneClass[$related.demand]
    $relatedTrendTone = $toneClass[$related.trend]

@"
          <article class="card related-card">
            <div class="pet-row">
              <img class="pet-avatar" src="/assets/pets/$($related.slug).png" alt="$([System.Net.WebUtility]::HtmlEncode($related.name))">
              <div class="pet-name">
                <strong><a class="pet-link" href="/pets/$($related.slug).html">$([System.Net.WebUtility]::HtmlEncode($related.name))</a></strong>
                <small>$([System.Net.WebUtility]::HtmlEncode($related.segment)) - $([System.Net.WebUtility]::HtmlEncode($related.rarity))</small>
              </div>
            </div>
            <div class="catalog-meta">
              <span class="tone $relatedDemandTone">$([System.Net.WebUtility]::HtmlEncode($related.demand)) demand</span>
              <span class="tone $relatedTrendTone">$([System.Net.WebUtility]::HtmlEncode($related.trend))</span>
              <span class="value-tag">$(Format-Value ([double]$related.values.default))</span>
            </div>
          </article>
"@
  }

  $variantRows = foreach ($key in @("default", "noPotion", "neon", "neonNoPotion", "mega", "megaNoPotion")) {
    $value = $pet.values.$key
    if ($null -eq $value) { continue }
@"
                <li><span>$($variantLabels[$key])</span><span class="value-tag">$(Format-Value ([double]$value))</span></li>
"@
  }

  $title = "{0} Value Guide 2026 | The Patch" -f $pet.name
  $description = "{0} value guide from The Patch with live benchmark variants, demand notes, trade tips, and related Adopt Me comparisons." -f $pet.name
  $canonical = "https://thepatchgg.github.io/pets/{0}.html" -f $pet.slug
  $demandTone = $toneClass[$pet.demand]
  $trendTone = $toneClass[$pet.trend]
  $confidenceTone = if ($pet.confidence -eq "High") { "tone-strong" } else { "tone-beta" }
  $h1 = "{0} value guide" -f $pet.name

  $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$([System.Net.WebUtility]::HtmlEncode($title))</title>
  <meta name="description" content="$([System.Net.WebUtility]::HtmlEncode($description))">
  <meta name="theme-color" content="#08111f">
  <meta property="og:type" content="article">
  <meta property="og:title" content="$([System.Net.WebUtility]::HtmlEncode($title))">
  <meta property="og:description" content="$([System.Net.WebUtility]::HtmlEncode($description))">
  <meta property="og:url" content="$canonical">
  <meta property="og:site_name" content="The Patch">
  <meta property="og:image" content="https://thepatchgg.github.io/assets/pets/$($pet.slug).png">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="$([System.Net.WebUtility]::HtmlEncode($title))">
  <meta name="twitter:description" content="$([System.Net.WebUtility]::HtmlEncode($description))">
  <meta name="twitter:image" content="https://thepatchgg.github.io/assets/pets/$($pet.slug).png">
  <link rel="canonical" href="$canonical">
  <link rel="icon" href="/favicon.svg" type="image/svg+xml">
  <link rel="manifest" href="/site.webmanifest">
  <link rel="stylesheet" href="/assets/css/adopt-tools.css">
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-KXQR564341"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-KXQR564341');
  </script>
</head>
<body>
  <header class="site-header">
    <div class="header-inner">
      <a class="brand" href="/">
        <span class="brand-mark" aria-hidden="true"></span>
        <span>The Patch</span>
      </a>
      <nav class="nav" aria-label="Primary">
        <a href="/">Home</a>
        <a href="/articles/adopt-me-pet-value-list-2026.html">Pet Values</a>
        <a href="/pet-value-calculator.html">Trade Calculator</a>
        <a href="/market-movers.html">Market Movers</a>
        <a href="/adopt-me.html">Guides</a>
      </nav>
    </div>
  </header>

  <main>
    <section class="page-hero">
      <div class="shell detail-hero">
        <div class="detail-hero-copy">
          <div class="eyebrow">Benchmark pet page</div>
          <h1>$([System.Net.WebUtility]::HtmlEncode($h1))</h1>
          <p>$([System.Net.WebUtility]::HtmlEncode($profile.summary))</p>
          <div class="cta-row">
            <a class="button primary" href="/pet-value-calculator.html">Compare a trade</a>
            <a class="button secondary" href="/articles/adopt-me-pet-value-list-2026.html">Back to the value list</a>
          </div>
        </div>
        <aside class="hero-panel detail-hero-panel">
          <div class="pet-row">
            <img class="pet-avatar detail-avatar" src="/assets/pets/$($pet.slug).png" alt="$([System.Net.WebUtility]::HtmlEncode($pet.name))">
            <div class="pet-name">
              <strong>$([System.Net.WebUtility]::HtmlEncode($pet.name))</strong>
              <small>$([System.Net.WebUtility]::HtmlEncode($pet.segment)) - $([System.Net.WebUtility]::HtmlEncode($pet.rarity))</small>
            </div>
          </div>
          <div class="catalog-meta">
            <span class="tone $demandTone">$([System.Net.WebUtility]::HtmlEncode($pet.demand)) demand</span>
            <span class="tone $trendTone">$([System.Net.WebUtility]::HtmlEncode($pet.trend))</span>
            <span class="tone $confidenceTone">$([System.Net.WebUtility]::HtmlEncode($pet.confidence)) confidence</span>
          </div>
          <ul class="mini-list detail-kpis">
            <li><span>Default</span><span class="value-tag">$(Format-Value ([double]$pet.values.default))</span></li>
            <li><span>No Potion</span><span class="value-tag">$(Format-Value ([double]$pet.values.noPotion))</span></li>
            <li><span>Neon</span><span class="value-tag">$(Format-Value ([double]$pet.values.neon))</span></li>
          </ul>
          <button class="ghost-button watch-button" type="button" data-watch-pet>Watch this pet</button>
        </aside>
      </div>
    </section>

    <section class="section">
      <div class="shell detail-grid">
        <section class="tool-card stack detail-main">
          <div class="section-head">
            <div>
              <h2>Why traders keep checking $([System.Net.WebUtility]::HtmlEncode($pet.name))</h2>
              <p class="intro-copy">$([System.Net.WebUtility]::HtmlEncode($profile.origin))</p>
            </div>
          </div>
          <div class="card-grid detail-card-grid">
            <article class="card">
              <h3>Liquidity read</h3>
              <p>$([System.Net.WebUtility]::HtmlEncode($profile.liquidity))</p>
            </article>
            <article class="card">
              <h3>Trade tip</h3>
              <p>$([System.Net.WebUtility]::HtmlEncode($profile.tradeTip))</p>
            </article>
            <article class="card">
              <h3>Why watch this page</h3>
              <p>$([System.Net.WebUtility]::HtmlEncode($profile.watchReason))</p>
            </article>
            <article class="card">
              <h3>Patch note</h3>
              <p>$([System.Net.WebUtility]::HtmlEncode($pet.notes))</p>
            </article>
          </div>
        </section>

        <aside class="tool-card stack detail-sidebar">
          <div>
            <h2>Variant values</h2>
            <p class="micro-copy">The Patch treats potions and neon status as real market lanes, not flat multipliers.</p>
          </div>
          <ul class="mini-list variant-list">
$($variantRows -join "`r`n")
          </ul>
          <div class="stack-actions">
            <a class="pill-link" href="/neon-calculator.html">Check neon math</a>
            <a class="pill-link" href="/methodology.html">Read methodology</a>
            <a class="pill-link" href="/inventory-planner.html">Plan upgrades</a>
          </div>
        </aside>
      </div>
    </section>

    <section class="section">
      <div class="shell">
        <div class="section-head">
          <div>
            <h2>Compare with nearby benchmark pets</h2>
            <p class="intro-copy">These pages sit closest to $([System.Net.WebUtility]::HtmlEncode($pet.name)) in real trade conversations and give useful sanity checks before overpaying.</p>
          </div>
        </div>
        <div class="card-grid">
$($relatedCards -join "`r`n")
        </div>
      </div>
    </section>
  </main>

  <footer class="footer">
    <div class="footer-inner">
      <div class="footer-copy">$([System.Net.WebUtility]::HtmlEncode($pet.name)) was last reviewed in the shared benchmark system on April 9, 2026.</div>
      <nav class="nav" aria-label="Footer">
        <a href="/articles/adopt-me-pet-value-list-2026.html">Values</a>
        <a href="/pet-value-calculator.html">Calculator</a>
        <a href="/market-movers.html">Market Movers</a>
        <a href="/corrections.html">Corrections</a>
      </nav>
    </div>
  </footer>

  <script>window.THE_PATCH_PET_SLUG = "$($pet.slug)";</script>
  <script src="/assets/js/adopt-retention.js"></script>
  <script src="/assets/js/adopt-pet-pages.js"></script>
</body>
</html>
"@

  $target = Join-Path $petsDir ("{0}.html" -f $pet.slug)
  Set-Content -Path $target -Value $html -Encoding UTF8
}
