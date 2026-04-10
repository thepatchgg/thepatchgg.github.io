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

function Join-Names {
  param([string[]]$Names)

  if (-not $Names -or $Names.Count -eq 0) {
    return ""
  }

  if ($Names.Count -eq 1) {
    return $Names[0]
  }

  if ($Names.Count -eq 2) {
    return "{0} and {1}" -f $Names[0], $Names[1]
  }

  return "{0}, and {1}" -f ($Names[0..($Names.Count - 2)] -join ", "), $Names[-1]
}

if (-not (Test-Path -LiteralPath $petsDir)) {
  New-Item -ItemType Directory -Path $petsDir | Out-Null
}

foreach ($pet in $values.pets) {
  $profile = $profiles.PSObject.Properties[$pet.slug].Value
  if (-not $profile) {
    continue
  }

  $relatedPets = foreach ($relatedSlug in $profile.compareWith) {
    $related = $values.pets | Where-Object { $_.slug -eq $relatedSlug } | Select-Object -First 1
    if (-not $related) { continue }
    $related
  }

  $relatedCards = foreach ($related in $relatedPets) {

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

  $relatedNames = @($relatedPets | ForEach-Object { $_.name })
  $relatedLabel = Join-Names -Names $relatedNames
  $defaultValueText = Format-Value ([double]$pet.values.default)
  $noPotionValueText = Format-Value ([double]$pet.values.noPotion)
  $noPotionDeltaText = Format-Value ([double][math]::Abs([double]$pet.values.noPotion - [double]$pet.values.default))
  $benchmarkAnswer = "{0} currently carries {1} demand with {2} confidence. The current signal is {3}, so it works best as a {4} comparison page rather than a guaranteed server price." -f $pet.name, $pet.demand.ToLowerInvariant(), $pet.confidence.ToLowerInvariant(), $pet.trend.ToLowerInvariant(), $pet.segment.ToLowerInvariant()
  if ([double]$pet.values.noPotion -gt [double]$pet.values.default) {
    $noPotionAnswer = "Right now, no-potion {0} sits at {1} versus {2} for the default version, so collectors are paying about {3} more for the cleaner lane." -f $pet.name, $noPotionValueText, $defaultValueText, $noPotionDeltaText
  } elseif ([double]$pet.values.noPotion -lt [double]$pet.values.default) {
    $noPotionAnswer = "Right now, no-potion {0} sits at {1} versus {2} for the default version, so the clean copy is slightly softer by about {3} in this lane." -f $pet.name, $noPotionValueText, $defaultValueText, $noPotionDeltaText
  } else {
    $noPotionAnswer = "Right now, no-potion and default {0} are valued the same, which is a reminder that not every pet gets a collector premium." -f $pet.name
  }
  $compareAnswer = "The best sanity checks right now are {0}. Those pages sit close to {1} in real trade conversations and help you spot whether a server is drifting too far from broader market behavior." -f $relatedLabel, $pet.name
  $faqItems = @(
    [pscustomobject]@{
      question = "How strong is $($pet.name) in trades right now?"
      answer = $benchmarkAnswer
    },
    [pscustomobject]@{
      question = "Why does no-potion $($pet.name) have a different value?"
      answer = $noPotionAnswer
    },
    [pscustomobject]@{
      question = "Which pets should I compare with $($pet.name)?"
      answer = $compareAnswer
    }
  )
  $faqMarkup = foreach ($item in $faqItems) {
@"
          <article class="faq-item">
            <h3>$([System.Net.WebUtility]::HtmlEncode($item.question))</h3>
            <p>$([System.Net.WebUtility]::HtmlEncode($item.answer))</p>
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
  $description = "{0} value guide from The Patch with live value lanes, demand notes, trade tips, and related Adopt Me comparisons." -f $pet.name
  $canonical = "https://thepatchgg.github.io/pets/{0}.html" -f $pet.slug
  $demandTone = $toneClass[$pet.demand]
  $trendTone = $toneClass[$pet.trend]
  $confidenceTone = if ($pet.confidence -eq "High") { "tone-strong" } else { "tone-beta" }
  $h1 = "{0} value guide" -f $pet.name
  $schema = @(
    [pscustomobject]@{
      '@context' = 'https://schema.org'
      '@type' = 'BreadcrumbList'
      itemListElement = @(
        [pscustomobject]@{
          '@type' = 'ListItem'
          position = 1
          name = 'Home'
          item = 'https://thepatchgg.github.io/'
        },
        [pscustomobject]@{
          '@type' = 'ListItem'
          position = 2
          name = 'Pet value library'
          item = 'https://thepatchgg.github.io/pets/'
        },
        [pscustomobject]@{
          '@type' = 'ListItem'
          position = 3
          name = $pet.name
          item = $canonical
        }
      )
    },
    [pscustomobject]@{
      '@context' = 'https://schema.org'
      '@type' = 'FAQPage'
      mainEntity = @(
        $faqItems | ForEach-Object {
          [pscustomobject]@{
            '@type' = 'Question'
            name = $_.question
            acceptedAnswer = [pscustomobject]@{
              '@type' = 'Answer'
              text = $_.answer
            }
          }
        }
      )
    }
  ) | ConvertTo-Json -Depth 8 -Compress

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
  <link rel="stylesheet" href="/style.css">
  <link rel="stylesheet" href="/assets/css/adopt-tools.css">
  <link rel="stylesheet" href="/assets/css/patch-compat.css">
  <script src="/assets/js/patch-ribbon.js"></script>
  <script type="application/ld+json">$schema</script>
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
        <a href="/pets/" class="active">Pet Library</a>
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
          <nav class="crumbs" aria-label="Breadcrumb">
            <a href="/">Home</a>
            <span aria-hidden="true">/</span>
            <a href="/pets/">Pet value library</a>
            <span aria-hidden="true">/</span>
            <span>$([System.Net.WebUtility]::HtmlEncode($pet.name))</span>
          </nav>
          <div class="eyebrow">Pet value page</div>
          <h1>$([System.Net.WebUtility]::HtmlEncode($h1))</h1>
          <p>$([System.Net.WebUtility]::HtmlEncode($profile.summary))</p>
          <div class="cta-row">
            <a class="button primary" href="/pet-value-calculator.html" data-track-event="pet_page_cta_click" data-track-location="hero_primary">Compare a trade</a>
            <a class="button secondary" href="/pets/" data-track-event="pet_page_cta_click" data-track-location="hero_secondary">Open pet library</a>
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
            <a class="pill-link" href="/articles/adopt-me-pet-value-list-2026.html">Open full value list</a>
          </div>
        </aside>
      </div>
    </section>

    <section class="section">
      <div class="shell">
        <div class="section-head">
          <div>
            <h2>Compare with nearby pet pages</h2>
            <p class="intro-copy">These pages sit closest to $([System.Net.WebUtility]::HtmlEncode($pet.name)) in real trade conversations and give useful sanity checks before overpaying.</p>
          </div>
        </div>
        <div class="card-grid">
$($relatedCards -join "`r`n")
        </div>
      </div>
    </section>

    <section class="section">
      <div class="shell detail-faq">
        <div class="section-head">
          <div>
            <h2>$([System.Net.WebUtility]::HtmlEncode($pet.name)) FAQ</h2>
            <p class="intro-copy">These quick answers cover demand, variants, and nearby comparison pets.</p>
          </div>
          <div class="section-actions">
            <a class="pill-link" href="/pets/">Pet library</a>
            <a class="pill-link" href="/market-movers.html">Market movers</a>
          </div>
        </div>
        <div class="faq-stack">
$($faqMarkup -join "`r`n")
        </div>
      </div>
    </section>
  </main>

  <footer class="footer">
    <div class="footer-inner">
      <div class="footer-copy">$([System.Net.WebUtility]::HtmlEncode($pet.name)) guide with value lanes, comparisons, and trade notes.</div>
      <nav class="nav" aria-label="Footer">
        <a href="/pets/">Pet Library</a>
        <a href="/articles/adopt-me-pet-value-list-2026.html">Values</a>
        <a href="/pet-value-calculator.html">Calculator</a>
        <a href="/market-movers.html">Market Movers</a>
        <a href="/corrections.html">Corrections</a>
        <a href="/privacy.html">Privacy</a>
      </nav>
    </div>
  </footer>

  <script>window.THE_PATCH_PET_SLUG = "$($pet.slug)";</script>
  <script src="/assets/js/adopt-retention.js"></script>
  <script src="/assets/js/adopt-analytics.js"></script>
  <script src="/assets/js/adopt-pet-pages.js"></script>
</body>
</html>
"@

  $target = Join-Path $petsDir ("{0}.html" -f $pet.slug)
  Set-Content -Path $target -Value $html -Encoding UTF8
}
