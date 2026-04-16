$repoRoot = Split-Path -Parent $PSScriptRoot
$valuesPath = Join-Path $repoRoot "data\adopt-me-values.json"
$profilesPath = Join-Path $repoRoot "data\adopt-me-benchmark-profiles.json"
$legacyPath = Join-Path $repoRoot "data\adopt-me-calculator-values.json"
$overridesPath = Join-Path $repoRoot "data\adopt-me-calculator-overrides.json"
$catalogPath = Join-Path $repoRoot "data\adopt-me-pet-catalog.json"
$petPagesDataPath = Join-Path $repoRoot "data\adopt-me-pet-pages.json"
$petsDir = Join-Path $repoRoot "pets"
$sitemapPath = Join-Path $repoRoot "sitemap.xml"
$today = Get-Date -Format "yyyy-MM-dd"

function Get-CoalescedValue {
  param([object[]]$Values)
  foreach ($value in $Values) {
    if ($null -eq $value) { continue }
    if ($value -is [string]) {
      if (-not [string]::IsNullOrWhiteSpace($value)) { return $value }
      continue
    }
    return $value
  }
  return $null
}

function HtmlEncode([string]$Value) {
  return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

function Normalize-RarityCode([string]$Rarity) {
  if ([string]::IsNullOrWhiteSpace($Rarity)) { return "review" }
  $normalized = $Rarity.Trim().ToLowerInvariant()
  $map = @{
    "legendary" = "l"
    "l" = "l"
    "ultra-rare" = "ur"
    "ultra rare" = "ur"
    "ur" = "ur"
    "rare" = "r"
    "r" = "r"
    "uncommon" = "u"
    "u" = "u"
    "common" = "c"
    "c" = "c"
    "event" = "event"
    "review" = "review"
    "needs review" = "review"
  }
  if ($map.ContainsKey($normalized)) { return $map[$normalized] }
  return "review"
}

function Get-RarityLabel([string]$RarityCode) {
  $map = @{
    "l" = "Legendary"
    "ur" = "Ultra-Rare"
    "r" = "Rare"
    "u" = "Uncommon"
    "c" = "Common"
    "event" = "Event"
    "review" = "Needs review"
  }
  return Get-CoalescedValue @($map[$RarityCode], "Needs review")
}

function Format-Value([double]$Value) {
  if ($Value -ge 1000) {
    return ((("{0:0.#}" -f ($Value / 1000)).TrimEnd("0").TrimEnd(".")) + "K")
  }
  if ($Value -eq [math]::Floor($Value)) {
    return [string][int]$Value
  }
  if ($Value -lt 10) {
    return ("{0:0.00}" -f $Value).TrimEnd("0").TrimEnd(".")
  }
  return ("{0:0.0}" -f $Value).TrimEnd("0").TrimEnd(".")
}

function Join-Names([string[]]$Names) {
  if (-not $Names -or $Names.Count -eq 0) { return "" }
  if ($Names.Count -eq 1) { return $Names[0] }
  if ($Names.Count -eq 2) { return "{0} and {1}" -f $Names[0], $Names[1] }
  return "{0}, and {1}" -f ($Names[0..($Names.Count - 2)] -join ", "), $Names[-1]
}

function Get-Segment([double]$Value) {
  if ($Value -ge 100) { return "High tier" }
  if ($Value -ge 25) { return "Upper mid tier" }
  if ($Value -ge 8) { return "Mid tier" }
  if ($Value -ge 2) { return "Lower mid tier" }
  return "Entry tier"
}

function Get-SitemapPriority([double]$Value) {
  if ($Value -ge 100) { return "0.8" }
  if ($Value -ge 25) { return "0.7" }
  if ($Value -ge 8) { return "0.6" }
  return "0.5"
}

function Convert-OverrideValues($Matrix) {
  $default = if ($null -ne $Matrix.default.flyRide) { [double]$Matrix.default.flyRide } else { [double]$Matrix.default.noPotion }
  $noPotion = if ($null -ne $Matrix.default.noPotion) { [double]$Matrix.default.noPotion } else { $default }
  $neon = if ($null -ne $Matrix.neon.flyRide) { [double]$Matrix.neon.flyRide } else { [double]$Matrix.neon.noPotion }
  $neonNoPotion = if ($null -ne $Matrix.neon.noPotion) { [double]$Matrix.neon.noPotion } else { $neon }
  $mega = if ($null -ne $Matrix.mega.flyRide) { [double]$Matrix.mega.flyRide } else { [double]$Matrix.mega.noPotion }
  $megaNoPotion = if ($null -ne $Matrix.mega.noPotion) { [double]$Matrix.mega.noPotion } else { $mega }
  return [ordered]@{
    default = $default
    noPotion = $noPotion
    neon = $neon
    neonNoPotion = $neonNoPotion
    mega = $mega
    megaNoPotion = $megaNoPotion
  }
}

function Add-SitemapUrl([xml]$Sitemap, [System.Xml.XmlElement]$Parent, [string]$Loc, [string]$LastMod, [string]$ChangeFreq, [string]$Priority) {
  $ns = "http://www.sitemaps.org/schemas/sitemap/0.9"
  $urlNode = $Sitemap.CreateElement("url", $ns)
  foreach ($pair in @(
    @{ n = "loc"; v = $Loc },
    @{ n = "lastmod"; v = $LastMod },
    @{ n = "changefreq"; v = $ChangeFreq },
    @{ n = "priority"; v = $Priority }
  )) {
    $node = $Sitemap.CreateElement($pair.n, $ns)
    $node.InnerText = $pair.v
    [void]$urlNode.AppendChild($node)
  }
  [void]$Parent.AppendChild($urlNode)
}

if (-not (Test-Path -LiteralPath $petsDir)) {
  New-Item -ItemType Directory -Path $petsDir | Out-Null
}

$values = Get-Content -Raw -Path $valuesPath | ConvertFrom-Json
$profiles = (Get-Content -Raw -Path $profilesPath | ConvertFrom-Json).profiles
$legacy = Get-Content -Raw -Path $legacyPath | ConvertFrom-Json
$overrides = Get-Content -Raw -Path $overridesPath | ConvertFrom-Json
$catalog = Get-Content -Raw -Path $catalogPath | ConvertFrom-Json

$toneClass = @{
  "Elite" = "tone-elite"
  "Very High" = "tone-very-high"
  "High" = "tone-high"
  "Medium" = "tone-medium"
  "Low" = "tone-low"
  "Rising" = "tone-rising"
  "Steady" = "tone-steady"
  "Falling" = "tone-falling"
  "Benchmark anchor" = "tone-strong"
  "Current guide" = "tone-high"
  "Reference lane" = "tone-medium"
}

$variantLabels = @{
  "default" = "Default"
  "noPotion" = "No Potion"
  "neon" = "Neon"
  "neonNoPotion" = "Neon No Potion"
  "mega" = "Mega Neon"
  "megaNoPotion" = "Mega No Potion"
}

$comparisonGuideMap = @{
  "bat-dragon" = @([pscustomobject]@{ href = "/articles/adopt-me-bat-dragon-vs-shadow-dragon-guide.html"; title = "Bat Dragon vs Shadow Dragon"; description = "Use the direct comparison guide when you want the cleanest top-tier sanity check before a major overpay." })
  "shadow-dragon" = @([pscustomobject]@{ href = "/articles/adopt-me-bat-dragon-vs-shadow-dragon-guide.html"; title = "Bat Dragon vs Shadow Dragon"; description = "Use the direct comparison guide when you want the cleanest top-tier sanity check before a major overpay." })
  "owl" = @([pscustomobject]@{ href = "/articles/adopt-me-owl-vs-parrot-guide.html"; title = "Owl vs Parrot"; description = "This guide shows why Owl keeps outperforming pure rarity logic and why Parrot still matters so much in real trades." })
  "parrot" = @([pscustomobject]@{ href = "/articles/adopt-me-owl-vs-parrot-guide.html"; title = "Owl vs Parrot"; description = "This guide shows why Owl keeps outperforming pure rarity logic and why Parrot still matters so much in real trades." })
  "frost-dragon" = @([pscustomobject]@{ href = "/articles/adopt-me-frost-dragon-vs-giraffe-guide.html"; title = "Frost Dragon vs Giraffe"; description = "Use this comparison when you want to weigh raw value against trade liquidity in the high tier." })
  "giraffe" = @([pscustomobject]@{ href = "/articles/adopt-me-frost-dragon-vs-giraffe-guide.html"; title = "Frost Dragon vs Giraffe"; description = "Use this comparison when you want to weigh raw value against trade liquidity in the high tier." })
  "crow" = @([pscustomobject]@{ href = "/articles/adopt-me-crow-vs-evil-unicorn-guide.html"; title = "Crow vs Evil Unicorn"; description = "A useful read when you are deciding between two of the site's strongest upper-mid anchors." })
  "evil-unicorn" = @([pscustomobject]@{ href = "/articles/adopt-me-crow-vs-evil-unicorn-guide.html"; title = "Crow vs Evil Unicorn"; description = "A useful read when you are deciding between two of the site's strongest upper-mid anchors." })
  "turtle" = @([pscustomobject]@{ href = "/articles/adopt-me-turtle-vs-kangaroo-guide.html"; title = "Turtle vs Kangaroo"; description = "Use the direct comparison guide when you want the cleanest read on this everyday upgrade debate." })
  "kangaroo" = @([pscustomobject]@{ href = "/articles/adopt-me-turtle-vs-kangaroo-guide.html"; title = "Turtle vs Kangaroo"; description = "Use the direct comparison guide when you want the cleanest read on this everyday upgrade debate." })
}

$benchmarkIndex = @{}
foreach ($pet in $values.pets) { $benchmarkIndex[$pet.slug] = $pet }

$overrideIndex = @{}
foreach ($pet in $overrides.pets) { $overrideIndex[$pet.slug] = $pet }

$catalogIndex = @{}
foreach ($entry in $catalog.entries) { $catalogIndex[$entry.slug] = $entry }

$allPets = New-Object System.Collections.Generic.List[object]

foreach ($legacyPet in $legacy.pets) {
  $catalogEntry = $catalogIndex[$legacyPet.slug]
  $benchmarkPet = $benchmarkIndex[$legacyPet.slug]
  $overridePet = $overrideIndex[$legacyPet.slug]

  if ($benchmarkPet) {
    $rarityCode = Normalize-RarityCode ([string](Get-CoalescedValue @($catalogEntry.rarity, $benchmarkPet.rarity)))
    $record = [pscustomobject]@{
      slug = $benchmarkPet.slug
      name = $benchmarkPet.name
      rarityCode = $rarityCode
      rarity = Get-RarityLabel $rarityCode
      image = [string](Get-CoalescedValue @($catalogEntry.image, $legacyPet.image, "/assets/pets/$($benchmarkPet.slug).png"))
      source = "benchmark"
      benchmark = $true
      segment = $benchmarkPet.segment
      demand = $benchmarkPet.demand
      trend = $benchmarkPet.trend
      confidence = $benchmarkPet.confidence
      values = [ordered]@{
        default = [double]$benchmarkPet.values.default
        noPotion = [double]$benchmarkPet.values.noPotion
        neon = [double]$benchmarkPet.values.neon
        neonNoPotion = [double]$benchmarkPet.values.neonNoPotion
        mega = [double]$benchmarkPet.values.mega
        megaNoPotion = [double]$benchmarkPet.values.megaNoPotion
      }
      notes = $benchmarkPet.notes
      pageLabel = "Benchmark anchor"
      supportLabel = "$($benchmarkPet.demand) demand"
      supportTone = $benchmarkPet.trend
    }
  } elseif ($overridePet) {
    $vals = Convert-OverrideValues $overridePet.values
    $rarityCode = Normalize-RarityCode ([string](Get-CoalescedValue @($catalogEntry.rarity, $legacyPet.rarity)))
    $record = [pscustomobject]@{
      slug = $legacyPet.slug
      name = [string](Get-CoalescedValue @($overridePet.name, $legacyPet.name))
      rarityCode = $rarityCode
      rarity = Get-RarityLabel $rarityCode
      image = [string](Get-CoalescedValue @($catalogEntry.image, $legacyPet.image, "/assets/pets/$($legacyPet.slug).png"))
      source = "override"
      benchmark = $false
      segment = Get-Segment([double]$vals.default)
      demand = "Reference"
      trend = "Current lane"
      confidence = "Calculator"
      values = $vals
      notes = "This page follows the same broad value lane used by the site's calculator for current long-tail trade checks."
      pageLabel = "Current guide"
      supportLabel = Get-Segment([double]$vals.default)
      supportTone = "Current guide"
    }
  } else {
    $legacyValue = [double]$legacyPet.legacyValue
    $rarityCode = Normalize-RarityCode ([string](Get-CoalescedValue @($catalogEntry.rarity, $legacyPet.rarity)))
    $record = [pscustomobject]@{
      slug = $legacyPet.slug
      name = $legacyPet.name
      rarityCode = $rarityCode
      rarity = Get-RarityLabel $rarityCode
      image = [string](Get-CoalescedValue @($catalogEntry.image, $legacyPet.image, "/assets/pets/$($legacyPet.slug).png"))
      source = "legacy"
      benchmark = $false
      segment = Get-Segment($legacyValue)
      demand = "Reference"
      trend = "Current lane"
      confidence = "Calculator"
      values = [ordered]@{
        default = $legacyValue
        noPotion = $legacyValue
        neon = [double]($legacyValue * 4)
        neonNoPotion = [double]($legacyValue * 4)
        mega = [double]($legacyValue * 16)
        megaNoPotion = [double]($legacyValue * 16)
      }
      notes = "This page uses the baseline calculator lane for quick comparisons."
      pageLabel = "Reference lane"
      supportLabel = Get-Segment($legacyValue)
      supportTone = "Reference lane"
    }
  }

  $allPets.Add($record)
}

$allPets = @(
  $allPets |
  Sort-Object @{ Expression = { [double]$_.values.default }; Descending = $true }, @{ Expression = { $_.name } }
)

$petIndex = @{}
foreach ($pet in $allPets) { $petIndex[$pet.slug] = $pet }

$generatedPets = New-Object System.Collections.Generic.List[object]

foreach ($pet in $allPets) {
  $profileProperty = $profiles.PSObject.Properties[$pet.slug]
  $profile = if ($profileProperty) { $profileProperty.Value } else { $null }

  if ($profile -and $profile.compareWith) {
    $compareSlugs = @($profile.compareWith)
  } else {
    $compareSlugs = @(
      $allPets |
      Where-Object { $_.slug -ne $pet.slug } |
      Sort-Object @{
        Expression = {
          [math]::Abs([double]$_.values.default - [double]$pet.values.default) +
          ($(if ($_.rarityCode -ne $pet.rarityCode) { 1 } else { 0 })) +
          ($(if ($_.segment -ne $pet.segment) { 0.5 } else { 0 }))
        }
      } |
      Select-Object -First 3 -ExpandProperty slug
    )
  }

  $relatedPets = @($compareSlugs | ForEach-Object { $petIndex[$_] } | Where-Object { $_ })
  $relatedLabel = Join-Names @($relatedPets | ForEach-Object { $_.name })

  if (-not $profile) {
    $profile = [pscustomobject]@{
      summary = if ($pet.source -eq "benchmark") {
        "$($pet.name) is one of the clearer comparison anchors in the $($pet.segment.ToLowerInvariant()) range because traders keep using it as a practical checkpoint."
      } else {
        "$($pet.name) is a useful $($pet.segment.ToLowerInvariant()) reference page for keeping everyday trades grounded in the same lane as the site calculator."
      }
      origin = if ($pet.source -eq "benchmark") {
        "This page works best as an editorial anchor for nearby trades, upgrades, and side-by-side pet comparisons."
      } else {
        "This page follows the same broad long-tail value lane used by the site calculator, so it is most helpful as a quick compare point for live trading."
      }
      liquidity = switch ($pet.segment) {
        "High tier" { "$($pet.name) sits high enough on the board that even small gaps matter, so this page is best used before trusting a single headline number." }
        "Upper mid tier" { "$($pet.name) is a strong compare page when you are weighing better adds, cleaner upgrades, and collector pressure." }
        "Mid tier" { "$($pet.name) works best as an everyday sanity-check pet rather than a dramatic overpay target." }
        "Lower mid tier" { "$($pet.name) helps keep smaller bundles grounded when a deal starts leaning too hard on hype." }
        default { "$($pet.name) is best treated as a low-end compare point when you want weaker adds to stay realistic." }
      }
      tradeTip = "Before you move on $($pet.name), compare it against $relatedLabel. Those nearby pages are the fastest way to see whether an offer is really in the right lane."
      watchReason = switch ($pet.segment) {
        "High tier" { "Watch this page when you want to see whether a high-ticket pet outside the benchmark set is starting to behave like a true anchor." }
        "Upper mid tier" { "Watch this page when you want a stronger read on upgrade pets that sit just below the main anchors." }
        "Mid tier" { "Watch this page when you want a practical read on everyday trades without leaving the Patch pet library." }
        "Lower mid tier" { "Watch this page when you want to keep mid-sized bundles and side adds grounded in the same lane as the calculator." }
        default { "Watch this page when you want a cleaner low-end compare point than a generic rarity list can give you." }
      }
      compareWith = $compareSlugs
    }
  }

  $faqItems = @(
    [pscustomobject]@{
      question = "How should I use this $($pet.name) page?"
      answer = if ($pet.benchmark) {
        "$($pet.name) works best as a benchmark anchor for $($pet.segment.ToLowerInvariant()) trades, especially when you want a cleaner read on nearby pets before you overpay."
      } else {
        "$($pet.name) works best as a current reference page for everyday trades in the $($pet.segment.ToLowerInvariant()) range, using the same broad value lane the site calculator relies on."
      }
    },
    [pscustomobject]@{
      question = "Why does no-potion $($pet.name) look different from the default lane?"
      answer = if ([double]$pet.values.noPotion -gt [double]$pet.values.default) {
        "Right now, no-potion $($pet.name) sits at $(Format-Value([double]$pet.values.noPotion)) versus $(Format-Value([double]$pet.values.default)) for the default version, so collectors are paying about $(Format-Value([double][math]::Abs([double]$pet.values.noPotion - [double]$pet.values.default))) more for the cleaner lane."
      } elseif ([double]$pet.values.noPotion -lt [double]$pet.values.default) {
        "Right now, no-potion $($pet.name) sits at $(Format-Value([double]$pet.values.noPotion)) versus $(Format-Value([double]$pet.values.default)) for the default version, so the cleaner copy is slightly softer by about $(Format-Value([double][math]::Abs([double]$pet.values.noPotion - [double]$pet.values.default))) in this lane."
      } else {
        "Right now, no-potion and default $($pet.name) land in the same lane, which is a reminder that not every pet gets a collector premium."
      }
    },
    [pscustomobject]@{
      question = "Which pets should I compare with $($pet.name)?"
      answer = "The fastest sanity checks right now are $relatedLabel. Those pages sit close enough to $($pet.name) that they help you keep offers grounded before you move ahead."
    }
  )

  $faqMarkup = foreach ($item in $faqItems) {
@"
          <article class="faq-item">
            <h3>$(HtmlEncode $item.question)</h3>
            <p>$(HtmlEncode $item.answer)</p>
          </article>
"@
  }

  $relatedCards = foreach ($related in $relatedPets) {
    $relatedTone = Get-CoalescedValue @($toneClass[$related.pageLabel], "tone-medium")
    $relatedSupportTone = Get-CoalescedValue @($toneClass[$related.supportTone], "tone-medium")
@"
          <article class="card related-card">
            <div class="pet-row">
              <img class="pet-avatar" src="$($related.image)" alt="$(HtmlEncode $related.name)">
              <div class="pet-name">
                <strong><a class="pet-link" href="/pets/$($related.slug).html">$(HtmlEncode $related.name)</a></strong>
                <small>$(HtmlEncode $related.segment) - $(HtmlEncode $related.rarity)</small>
              </div>
            </div>
            <div class="catalog-meta">
              <span class="tone $relatedTone">$(HtmlEncode $related.pageLabel)</span>
              <span class="tone $relatedSupportTone">$(HtmlEncode $related.supportLabel)</span>
              <span class="value-tag">$(Format-Value([double]$related.values.default))</span>
            </div>
          </article>
"@
  }

  $nextLinks = New-Object System.Collections.Generic.List[object]
  if ($comparisonGuideMap.ContainsKey($pet.slug)) {
    foreach ($entry in $comparisonGuideMap[$pet.slug]) { $nextLinks.Add($entry) }
  }
  foreach ($entry in @(
    [pscustomobject]@{ href = "/articles/adopt-me-pet-value-list-2026.html"; title = "Open the live value list"; description = "Use the value list when you want the short answer first before comparing both sides of a trade." },
    [pscustomobject]@{ href = "/articles/adopt-me-pet-encyclopedia.html"; title = "Browse the pet encyclopedia"; description = "Jump back into the full pet catalog when this page turns into a wider research session." },
    [pscustomobject]@{ href = "/pet-value-calculator.html"; title = "Run the trade calculator"; description = "Switch from a single-pet read into a full trade comparison with potion lanes and both sides of the offer." }
  )) {
    $nextLinks.Add($entry)
  }
  $nextReadCards = foreach ($link in @($nextLinks | Select-Object -First 3)) {
@"
          <article class="card related-card">
            <h3 style="margin-bottom:8px;"><a class="pet-link" href="$($link.href)">$(HtmlEncode $link.title)</a></h3>
            <p>$(HtmlEncode $link.description)</p>
          </article>
"@
  }

  $variantRows = foreach ($key in @("default", "noPotion", "neon", "neonNoPotion", "mega", "megaNoPotion")) {
@"
                <li><span>$($variantLabels[$key])</span><span class="value-tag">$(Format-Value([double]$pet.values.$key))</span></li>
"@
  }

  $title = "{0} Value in Adopt Me 2026 | Trade Guide | The Patch" -f $pet.name
  $description = "Check current {0} value in Adopt Me with no-potion lanes, compare pages, and the next best links into calculators and guides." -f $pet.name
  $canonical = "https://thepatchgg.github.io/pets/{0}.html" -f $pet.slug
  $schema = @(
    [pscustomobject]@{
      '@context' = 'https://schema.org'
      '@type' = 'BreadcrumbList'
      itemListElement = @(
        [pscustomobject]@{ '@type' = 'ListItem'; position = 1; name = 'Home'; item = 'https://thepatchgg.github.io/' },
        [pscustomobject]@{ '@type' = 'ListItem'; position = 2; name = 'Pet value library'; item = 'https://thepatchgg.github.io/pets/' },
        [pscustomobject]@{ '@type' = 'ListItem'; position = 3; name = $pet.name; item = $canonical }
      )
    },
    [pscustomobject]@{
      '@context' = 'https://schema.org'
      '@type' = 'Article'
      headline = $title
      description = $description
      image = "https://thepatchgg.github.io$($pet.image)"
      mainEntityOfPage = $canonical
      author = [pscustomobject]@{
        '@type' = 'Organization'
        name = 'The Patch Staff'
        url = 'https://thepatchgg.github.io/the-patch-staff.html'
      }
      publisher = [pscustomobject]@{
        '@type' = 'Organization'
        name = 'The Patch'
        logo = [pscustomobject]@{
          '@type' = 'ImageObject'
          url = 'https://thepatchgg.github.io/favicon.svg'
        }
      }
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

  $pageTone = Get-CoalescedValue @($toneClass[$pet.pageLabel], "tone-medium")
  $supportTone = Get-CoalescedValue @($toneClass[$pet.supportTone], "tone-medium")

  $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$(HtmlEncode $title)</title>
  <meta name="description" content="$(HtmlEncode $description)">
  <meta name="robots" content="max-image-preview:large">
  <meta name="theme-color" content="#08111f">
  <meta property="og:type" content="article">
  <meta property="og:title" content="$(HtmlEncode $title)">
  <meta property="og:description" content="$(HtmlEncode $description)">
  <meta property="og:url" content="$canonical">
  <meta property="og:site_name" content="The Patch">
  <meta property="og:image" content="https://thepatchgg.github.io$($pet.image)">
  <meta property="og:image:alt" content="$(HtmlEncode $pet.name) featured on The Patch Adopt Me value guide">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="$(HtmlEncode $title)">
  <meta name="twitter:description" content="$(HtmlEncode $description)">
  <meta name="twitter:image" content="https://thepatchgg.github.io$($pet.image)">
  <meta name="twitter:image:alt" content="$(HtmlEncode $pet.name) featured on The Patch Adopt Me value guide">
  <link rel="canonical" href="$canonical">
  <link rel="icon" href="/favicon.svg" type="image/svg+xml">
  <link rel="manifest" href="/site.webmanifest">
  <link rel="stylesheet" href="/style.css">
  <link rel="stylesheet" href="/assets/css/adopt-tools.css">
  <link rel="stylesheet" href="/assets/css/patch-compat.css">
  <script src="/assets/js/patch-ribbon.js"></script>
  <script type="application/ld+json">$schema</script>
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-KXQR564341"></script>
  <script>window.dataLayer = window.dataLayer || []; function gtag(){dataLayer.push(arguments);} gtag('js', new Date()); gtag('config', 'G-KXQR564341');</script>
</head>
<body>
  <header class="site-header">
    <div class="header-inner">
      <a class="brand" href="/"><span class="brand-mark" aria-hidden="true"></span><span>The Patch</span></a>
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
            <span>$(HtmlEncode $pet.name)</span>
          </nav>
          <div class="eyebrow">$(HtmlEncode $pet.pageLabel)</div>
          <h1>$(HtmlEncode $pet.name) value guide</h1>
          <p>$(HtmlEncode $profile.summary)</p>
          <p class="detail-byline">Reviewed by <a href="/the-patch-staff.html">The Patch Staff</a> using the current Patch methodology and the broader pet-page library built across The Patch.</p>
          <div class="cta-row">
            <a class="button primary" href="/pet-value-calculator.html" data-track-event="pet_page_cta_click" data-track-location="hero_primary">Compare a trade</a>
            <a class="button secondary" href="/articles/adopt-me-pet-value-list-2026.html" data-track-event="pet_page_cta_click" data-track-location="hero_secondary">Open value list</a>
            <a class="button secondary" href="/articles/adopt-me-pet-encyclopedia.html" data-track-event="pet_page_cta_click" data-track-location="hero_tertiary">Browse pet encyclopedia</a>
          </div>
        </div>
        <aside class="hero-panel detail-hero-panel">
          <div class="pet-row">
            <img class="pet-avatar detail-avatar" src="$($pet.image)" alt="$(HtmlEncode $pet.name)">
            <div class="pet-name">
              <strong>$(HtmlEncode $pet.name)</strong>
              <small>$(HtmlEncode $pet.segment) - $(HtmlEncode $pet.rarity)</small>
            </div>
          </div>
          <div class="catalog-meta">
            <span class="tone $pageTone">$(HtmlEncode $pet.pageLabel)</span>
            <span class="tone $supportTone">$(HtmlEncode $pet.supportLabel)</span>
            <span class="value-tag">$(Format-Value([double]$pet.values.default))</span>
          </div>
          <ul class="mini-list detail-kpis">
            <li><span>Default</span><span class="value-tag">$(Format-Value([double]$pet.values.default))</span></li>
            <li><span>No Potion</span><span class="value-tag">$(Format-Value([double]$pet.values.noPotion))</span></li>
            <li><span>Neon</span><span class="value-tag">$(Format-Value([double]$pet.values.neon))</span></li>
          </ul>
          <button class="ghost-button watch-button" type="button" data-watch-pet>Watch this pet</button>
        </aside>
      </div>
    </section>
"@

  $html += @"
    <section class="section">
      <div class="shell detail-grid">
        <section class="tool-card stack detail-main">
          <div class="section-head">
            <div>
              <h2>Why traders keep checking $(HtmlEncode $pet.name)</h2>
              <p class="intro-copy">$(HtmlEncode $profile.origin)</p>
            </div>
          </div>
          <div class="card-grid detail-card-grid">
            <article class="card"><h3>Liquidity read</h3><p>$(HtmlEncode $profile.liquidity)</p></article>
            <article class="card"><h3>Trade tip</h3><p>$(HtmlEncode $profile.tradeTip)</p></article>
            <article class="card"><h3>Why watch this page</h3><p>$(HtmlEncode $profile.watchReason)</p></article>
            <article class="card"><h3>Patch note</h3><p>$(HtmlEncode $pet.notes)</p></article>
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
            <a class="pill-link" href="/pet-value-calculator.html">Run trade calculator</a>
            <a class="pill-link" href="/neon-calculator.html">Check neon math</a>
            <a class="pill-link" href="/articles/adopt-me-pet-value-list-2026.html">Open full value list</a>
            <a class="pill-link" href="/articles/adopt-me-pet-encyclopedia.html">Browse pet encyclopedia</a>
            <a class="pill-link" href="/articles/adopt-me-egg-guide.html">Open egg guide</a>
          </div>
        </aside>
      </div>
    </section>

    <section class="section">
      <div class="shell">
        <div class="section-head">
          <div>
            <h2>Compare with nearby pet pages</h2>
            <p class="intro-copy">These pages sit closest to $(HtmlEncode $pet.name) in real trade conversations and give useful sanity checks before overpaying.</p>
          </div>
        </div>
        <div class="card-grid">
$($relatedCards -join "`r`n")
        </div>
      </div>
    </section>

    <section class="section">
      <div class="shell">
        <div class="section-head">
          <div>
            <h2>Best next clicks from here</h2>
            <p class="intro-copy">Use these pages to keep moving once this pet page has done its job.</p>
          </div>
        </div>
        <div class="card-grid">
$($nextReadCards -join "`r`n")
        </div>
      </div>
    </section>

    <section class="section">
      <div class="shell detail-faq">
        <div class="section-head">
          <div>
            <h2>$(HtmlEncode $pet.name) FAQ</h2>
            <p class="intro-copy">These quick answers cover value lanes, nearby compare pages, and how to use this guide.</p>
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
      <div class="footer-copy">$(HtmlEncode $pet.name) guide with value lanes, nearby compares, and next-click links into the rest of The Patch.</div>
      <nav class="nav" aria-label="Footer">
        <a href="/pets/">Pet Library</a>
        <a href="/articles/adopt-me-pet-value-list-2026.html">Values</a>
        <a href="/pet-value-calculator.html">Calculator</a>
        <a href="/articles/adopt-me-pet-encyclopedia.html">Pet Encyclopedia</a>
        <a href="/market-movers.html">Market Movers</a>
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

  Set-Content -Path (Join-Path $petsDir ("{0}.html" -f $pet.slug)) -Value $html -Encoding UTF8

  $generatedPets.Add([pscustomobject]@{
    slug = $pet.slug
    name = $pet.name
    rarityCode = $pet.rarityCode
    rarity = $pet.rarity
    image = $pet.image
    source = $pet.source
    benchmark = $pet.benchmark
    segment = $pet.segment
    demand = $pet.demand
    trend = $pet.trend
    values = $pet.values
    notes = $pet.notes
    pageLabel = $pet.pageLabel
    supportLabel = $pet.supportLabel
    supportTone = $pet.supportTone
    pageUrl = "/pets/$($pet.slug).html"
    compareSlugs = $compareSlugs
  })
}

$benchmarkCount = ($generatedPets | Where-Object { $_.benchmark -eq $true } | Measure-Object).Count
$currentGuideCount = ($generatedPets | Where-Object { $_.pageLabel -eq "Current guide" } | Measure-Object).Count
$referenceLaneCount = ($generatedPets | Where-Object { $_.pageLabel -eq "Reference lane" } | Measure-Object).Count
$generatedPetArray = [object[]]$generatedPets.ToArray()

$petPagesPayload = @{
  generatedAt = $today
  count = $generatedPets.Count
  counts = @{
    benchmark = $benchmarkCount
    currentGuide = $currentGuideCount
    referenceLane = $referenceLaneCount
  }
  pets = $generatedPetArray
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText(
  $petPagesDataPath,
  ($petPagesPayload | ConvertTo-Json -Depth 8),
  $utf8NoBom
)

[xml]$sitemap = Get-Content -Raw -Path $sitemapPath
$ns = New-Object System.Xml.XmlNamespaceManager($sitemap.NameTable)
$ns.AddNamespace("sm", "http://www.sitemaps.org/schemas/sitemap/0.9")
$urlset = $sitemap.urlset
@($sitemap.SelectNodes("//sm:url[starts-with(sm:loc,'https://thepatchgg.github.io/pets/')]", $ns)) | ForEach-Object {
  [void]$urlset.RemoveChild($_)
}

Add-SitemapUrl -Sitemap $sitemap -Parent $urlset -Loc "https://thepatchgg.github.io/pets/" -LastMod $today -ChangeFreq "weekly" -Priority "0.8"
foreach ($pet in $generatedPets) {
  Add-SitemapUrl -Sitemap $sitemap -Parent $urlset -Loc ("https://thepatchgg.github.io/pets/{0}.html" -f $pet.slug) -LastMod $today -ChangeFreq "weekly" -Priority (Get-SitemapPriority([double]$pet.values.default))
}
[System.IO.File]::WriteAllText($sitemapPath, $sitemap.OuterXml, $utf8NoBom)
