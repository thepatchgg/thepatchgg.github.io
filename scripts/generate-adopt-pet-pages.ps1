$repoRoot = Split-Path -Parent $PSScriptRoot
$valuesPath = Join-Path $repoRoot "data\adopt-me-values.json"
$profilesPath = Join-Path $repoRoot "data\adopt-me-benchmark-profiles.json"
$legacyPath = Join-Path $repoRoot "data\adopt-me-calculator-values.json"
$overridesPath = Join-Path $repoRoot "data\adopt-me-calculator-overrides.json"
$catalogPath = Join-Path $repoRoot "data\adopt-me-pet-catalog.json"
$eggsPath = Join-Path $repoRoot "data\adopt-me-audited-eggs.json"
$originOverridesPath = Join-Path $repoRoot "data\adopt-me-pet-origin-overrides.json"
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

function Normalize-Key([string]$Text) {
  if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
  $normalized = $Text.ToLowerInvariant()
  $normalized = $normalized -replace "&amp;", "and"
  $normalized = $normalized -replace "\(pet\)", ""
  $normalized = $normalized -replace "[^a-z0-9]+", "-"
  return $normalized.Trim("-")
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

function Get-NumericOrFallback {
  param(
    [object]$Value,
    [double]$Fallback
  )

  if ($null -eq $Value) {
    return $Fallback
  }

  $text = [string]$Value
  if ([string]::IsNullOrWhiteSpace($text)) {
    return $Fallback
  }

  return [double]$Value
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

function Get-ReleaseYear([string]$DateText) {
  if ([string]::IsNullOrWhiteSpace($DateText)) { return $null }
  $match = [regex]::Match($DateText, "(19|20)\d{2}")
  if ($match.Success) { return $match.Value }
  return $null
}

function Get-DateSortKey([string]$DateText) {
  if ([string]::IsNullOrWhiteSpace($DateText)) { return 999999 }
  $yearMatch = [regex]::Match($DateText, "(19|20)\d{2}")
  if (-not $yearMatch.Success) { return 999999 }

  $year = [int]$yearMatch.Value
  $monthValue = 6
  $monthMap = @{
    "jan" = 1
    "feb" = 2
    "mar" = 3
    "apr" = 4
    "may" = 5
    "jun" = 6
    "jul" = 7
    "aug" = 8
    "sep" = 9
    "oct" = 10
    "nov" = 11
    "dec" = 12
  }

  $monthMatch = [regex]::Match($DateText.ToLowerInvariant(), "jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec")
  if ($monthMatch.Success -and $monthMap.ContainsKey($monthMatch.Value)) {
    $monthValue = $monthMap[$monthMatch.Value]
  }

  return ($year * 100) + $monthValue
}

function Get-SourceTypeLabel([string]$SourceName) {
  if ([string]::IsNullOrWhiteSpace($SourceName)) { return "Source" }
  if ($SourceName -match "egg") { return "Egg" }
  if ($SourceName -match "doll|box|gift|crate|capsule") { return "Container" }
  return "Special source"
}

function Get-StatusLabel([string]$Status) {
  if ([string]::IsNullOrWhiteSpace($Status)) { return "Audit in progress" }
  switch ($Status.Trim().ToLowerInvariant()) {
    "current" { return "Currently available" }
    "available" { return "Currently available" }
    "retired" { return "Retired" }
    default { return (Get-Culture).TextInfo.ToTitleCase($Status.Trim().ToLowerInvariant()) }
  }
}

function Get-EventContext([object]$SourceEntry) {
  $candidates = @([string]$SourceEntry.cost, [string]$SourceEntry.notes, [string]$SourceEntry.name)
  foreach ($candidate in $candidates) {
    if ([string]::IsNullOrWhiteSpace($candidate)) { continue }
    $match = [regex]::Match($candidate, "\(([^)]*(event|festival|lab|countdown|solution)[^)]*)\)", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    if ($candidate -match "christmas|easter|sugarfest|moon|aztec|gru's lab|pet countdown") {
      return $candidate.Trim()
    }
  }
  return $null
}

function Get-PropertyValue($Object, [string]$Name) {
  if ($null -eq $Object) { return $null }
  $property = $Object.PSObject.Properties[$Name]
  if ($property) { return $property.Value }
  return $null
}

function Get-PetRarityBand([object]$SourceEntry, [string]$PetRarity, [int]$TotalPetsInSource) {
  if ($TotalPetsInSource -eq 1) { return "Guaranteed from this source" }
  $chanceMap = Get-PropertyValue $SourceEntry "chances"
  if ($null -eq $chanceMap -or [string]::IsNullOrWhiteSpace($PetRarity)) { return $null }
  $chanceValue = Get-PropertyValue $chanceMap $PetRarity
  if ([string]::IsNullOrWhiteSpace([string]$chanceValue)) { return $null }
  return "{0} hatch band: {1}" -f $PetRarity, $chanceValue
}

function Convert-OriginPetEntry([object]$EggPet) {
  $name = if ($EggPet.Count -ge 1) { [string]$EggPet[0] } else { "" }
  $rarity = ""
  $chance = $null

  if ($EggPet.Count -ge 3) {
    $thirdValue = [string]$EggPet[2]
    if ($thirdValue -match "%" -or $thirdValue -match "varies" -or $EggPet[2] -is [double] -or $EggPet[2] -is [int]) {
      $rarity = [string]$EggPet[1]
      $chance = [string]$EggPet[2]
    } else {
      $rarity = [string]$EggPet[2]
    }
  } elseif ($EggPet.Count -ge 2) {
    $rarity = [string]$EggPet[1]
  }

  return [pscustomobject]@{
    name = $name
    rarity = $rarity
    chance = $chance
  }
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
$eggs = (Get-Content -Raw -Path $eggsPath | ConvertFrom-Json).eggs
$originOverrides = if (Test-Path -LiteralPath $originOverridesPath) {
  (Get-Content -Raw -Path $originOverridesPath | ConvertFrom-Json).pets
} else {
  @()
}

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
  "default" = "Fly Ride"
  "fly" = "Fly"
  "ride" = "Ride"
  "noPotion" = "No Potion"
  "neon" = "Neon Fly Ride"
  "neonFly" = "Neon Fly"
  "neonRide" = "Neon Ride"
  "neonNoPotion" = "Neon No Potion"
  "mega" = "Mega Fly Ride"
  "megaFly" = "Mega Fly"
  "megaRide" = "Mega Ride"
  "megaNoPotion" = "Mega No Potion"
}

$benchmarkVariantKeys = @("default", "fly", "ride", "noPotion", "neon", "neonFly", "neonRide", "neonNoPotion", "mega", "megaFly", "megaRide", "megaNoPotion")
$referenceVariantKeys = @("default", "noPotion", "neon", "neonNoPotion", "mega", "megaNoPotion")

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
        fly = (Get-NumericOrFallback $benchmarkPet.values.fly ([double]$benchmarkPet.values.default))
        ride = (Get-NumericOrFallback $benchmarkPet.values.ride ([double]$benchmarkPet.values.default))
        noPotion = [double]$benchmarkPet.values.noPotion
        neon = [double]$benchmarkPet.values.neon
        neonFly = (Get-NumericOrFallback $benchmarkPet.values.neonFly ([double]$benchmarkPet.values.neon))
        neonRide = (Get-NumericOrFallback $benchmarkPet.values.neonRide ([double]$benchmarkPet.values.neon))
        neonNoPotion = [double]$benchmarkPet.values.neonNoPotion
        mega = [double]$benchmarkPet.values.mega
        megaFly = (Get-NumericOrFallback $benchmarkPet.values.megaFly ([double]$benchmarkPet.values.mega))
        megaRide = (Get-NumericOrFallback $benchmarkPet.values.megaRide ([double]$benchmarkPet.values.mega))
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

$manualOriginIndex = @{}
foreach ($entry in $originOverrides) {
  if (-not [string]::IsNullOrWhiteSpace([string]$entry.slug)) {
    $manualOriginIndex[$entry.slug] = $entry
  }
}

$originSlugAliases = @{
  "blue-jay-pet" = @("blue-jay")
  "dragonfruit-fox-pet" = @("dragonfruit-fox")
  "frost-fury-pet" = @("frost-fury")
  "karate-gorilla-pet" = @("karate-gorilla")
  "monkey-king-pet" = @("monkey-king")
  "mushroom-friend-pet" = @("mushroom-friend")
  "phoenix-pet" = @("phoenix")
  "princess-capuchin-monkey-pet" = @("princess-capuchin-monkey")
  "rosy-maple-moth-pet" = @("rosy-maple-moth")
  "tortuga-de-la-isla-pet" = @("tortuga-de-la-isla")
}

$originNameAliases = @{
  "wooly-mammoth" = "woolly-mammoth"
  "koi-fish" = "koi-carp"
}

$petLookup = @{}
foreach ($pet in $allPets) {
  $lookupCandidates = New-Object System.Collections.Generic.List[string]
  $lookupCandidates.Add((Normalize-Key $pet.name))
  $lookupCandidates.Add((Normalize-Key $pet.slug))
  if ($pet.slug -match "-pet$") {
    $lookupCandidates.Add((Normalize-Key ($pet.slug -replace "-pet$", "")))
  }
  if ($originSlugAliases.ContainsKey($pet.slug)) {
    foreach ($alias in $originSlugAliases[$pet.slug]) {
      $lookupCandidates.Add((Normalize-Key $alias))
    }
  }

  foreach ($candidate in ($lookupCandidates | Select-Object -Unique)) {
    if (-not [string]::IsNullOrWhiteSpace($candidate)) {
      $petLookup[$candidate] = $pet.slug
    }
  }
}

$petOrigins = @{}
foreach ($egg in $eggs) {
  $eggPets = @($egg.pets)
  $totalPetsInSource = $eggPets.Count

  foreach ($eggPet in $eggPets) {
    if ($null -eq $eggPet -or $eggPet.Count -lt 1) { continue }
    $petOriginEntry = Convert-OriginPetEntry $eggPet
    $petName = $petOriginEntry.name
    $petRarity = $petOriginEntry.rarity
    $lookupKey = Normalize-Key $petName
    if ($originNameAliases.ContainsKey($lookupKey)) {
      $lookupKey = $originNameAliases[$lookupKey]
    }
    if (-not $petLookup.ContainsKey($lookupKey)) { continue }

    $slug = $petLookup[$lookupKey]
    if (-not $petOrigins.ContainsKey($slug)) {
      $petOrigins[$slug] = New-Object System.Collections.Generic.List[object]
    }

    $petOrigins[$slug].Add([pscustomobject]@{
      sourceName = [string]$egg.name
      sourceType = Get-SourceTypeLabel ([string]$egg.name)
      status = [string]$egg.status
      statusLabel = Get-StatusLabel ([string]$egg.status)
      released = [string]$egg.released
      releaseYear = Get-ReleaseYear ([string]$egg.released)
      retired = [string](Get-CoalescedValue @($egg.retired))
      cost = [string](Get-CoalescedValue @($egg.cost))
      petRarity = $petRarity
      chanceText = [string](Get-CoalescedValue @($petOriginEntry.chance))
      rarityBand = if (-not [string]::IsNullOrWhiteSpace([string]$petOriginEntry.chance)) {
        "Exact hatch chance: $($petOriginEntry.chance)"
      } else {
        Get-PetRarityBand -SourceEntry $egg -PetRarity $petRarity -TotalPetsInSource $totalPetsInSource
      }
      eventContext = Get-EventContext $egg
      notes = [string](Get-CoalescedValue @($egg.notes))
      sortKey = Get-DateSortKey ([string]$egg.released)
    })
  }
}

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

  $originEntries = New-Object System.Collections.Generic.List[object]
  if ($manualOriginIndex.ContainsKey($pet.slug)) {
    foreach ($entry in @($manualOriginIndex[$pet.slug].sources)) {
      $originEntries.Add([pscustomobject]@{
        sourceName = [string](Get-CoalescedValue @($entry.sourceName))
        sourceType = [string](Get-CoalescedValue @($entry.sourceType, "Special source"))
        status = [string](Get-CoalescedValue @($entry.status, "retired"))
        statusLabel = Get-StatusLabel ([string](Get-CoalescedValue @($entry.status, "retired")))
        released = [string](Get-CoalescedValue @($entry.released))
        releaseYear = [string](Get-CoalescedValue @($entry.releaseYear, (Get-ReleaseYear ([string](Get-CoalescedValue @($entry.released))))))
        retired = [string](Get-CoalescedValue @($entry.retired))
        cost = [string](Get-CoalescedValue @($entry.cost))
        petRarity = [string](Get-CoalescedValue @($entry.petRarity))
        chanceText = [string](Get-CoalescedValue @($entry.chanceText))
        rarityBand = [string](Get-CoalescedValue @($entry.rarityBand))
        eventContext = [string](Get-CoalescedValue @($entry.eventContext))
        notes = [string](Get-CoalescedValue @($entry.notes))
        sortKey = if ($entry.PSObject.Properties["sortKey"]) { [int]$entry.sortKey } else { Get-DateSortKey ([string](Get-CoalescedValue @($entry.released))) }
      })
    }
  } elseif ($petOrigins.ContainsKey($pet.slug)) {
    foreach ($entry in ($petOrigins[$pet.slug].ToArray() | Sort-Object @{ Expression = { $_.sortKey } }, @{ Expression = { $_.sourceName } })) {
      $originEntries.Add($entry)
    }
  }
  $originEntryArray = @($originEntries.ToArray())
  $firstOrigin = if ($originEntries.Count -gt 0) { $originEntries[0] } else { $null }
  $currentOrigins = @($originEntryArray | Where-Object { @("available", "current") -contains $_.status })
  $originLabels = @($originEntryArray | ForEach-Object { $_.sourceName } | Select-Object -Unique)
  $currentOriginLabels = @($currentOrigins | ForEach-Object { $_.sourceName } | Select-Object -Unique)
  $eventLabels = @(
    $originEntryArray |
    ForEach-Object { $_.eventContext } |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Select-Object -Unique
  )
  $releaseYears = @(
    $originEntryArray |
    ForEach-Object { $_.releaseYear } |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Select-Object -Unique
  )
  $originSummary = [pscustomobject]@{
    audited = ($originEntries.Count -gt 0)
    sources = $originEntryArray
    sourceCount = $originEntries.Count
    firstSource = $firstOrigin
    currentSources = $currentOrigins
    currentSourceLabels = $currentOriginLabels
    sourceLabels = $originLabels
    eventLabels = $eventLabels
    releaseYears = $releaseYears
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
  if ($originSummary.audited) {
    $originAnswer = if ($originSummary.currentSourceLabels.Count -gt 0) {
      "$($pet.name) first shows up in the audited dataset through $($originSummary.firstSource.sourceName) from $($originSummary.firstSource.released). Right now, the current audited sources are $((Join-Names $originSummary.currentSourceLabels))."
    } else {
      "$($pet.name) first shows up in the audited dataset through $($originSummary.firstSource.sourceName) from $($originSummary.firstSource.released). That source is currently retired in the site's audited pet-origin data."
    }
    $faqItems += [pscustomobject]@{
      question = "Where did $($pet.name) come from in Adopt Me?"
      answer = $originAnswer
    }
  } else {
    $faqItems += [pscustomobject]@{
      question = "Do we know where $($pet.name) originally came from?"
      answer = "The Patch has current value lanes for $($pet.name), but the origin and release history for this pet is still being audited before we publish it on this page."
    }
  }

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

  $variantKeys = if ($pet.benchmark) { $benchmarkVariantKeys } else { $referenceVariantKeys }
  $variantRows = foreach ($key in $variantKeys) {
@"
                <li><span>$($variantLabels[$key])</span><span class="value-tag">$(Format-Value([double]$pet.values.$key))</span></li>
"@
  }

  $heroMetricRows = if ($pet.benchmark) {
    foreach ($key in @("default", "fly", "ride", "noPotion")) {
@"
            <li><span>$($variantLabels[$key])</span><span class="value-tag">$(Format-Value([double]$pet.values.$key))</span></li>
"@
    }
  } else {
    foreach ($key in @("default", "noPotion", "neon")) {
@"
            <li><span>$($variantLabels[$key])</span><span class="value-tag">$(Format-Value([double]$pet.values.$key))</span></li>
"@
    }
  }

  if ($originSummary.audited) {
    $firstSourceText = "$($originSummary.firstSource.sourceName)"
    if (-not [string]::IsNullOrWhiteSpace($originSummary.firstSource.released)) {
      $firstSourceText += " - first seen $($originSummary.firstSource.released)"
    }
    $currentSourceText = if ($originSummary.currentSourceLabels.Count -gt 0) {
      Join-Names $originSummary.currentSourceLabels
    } else {
      "No currently available audited source"
    }
    $releaseText = if ($originSummary.releaseYears.Count -gt 1) {
      "{0} through {1}" -f $originSummary.releaseYears[0], $originSummary.releaseYears[-1]
    } elseif ($originSummary.releaseYears.Count -eq 1) {
      $originSummary.releaseYears[0]
    } else {
      "Audit in progress"
    }
    $eventText = if ($originSummary.eventLabels.Count -gt 0) {
      Join-Names $originSummary.eventLabels
    } else {
      "No special event note in the audited source list"
    }
    $originSnapshotRows = @(
      @{ label = "First audited source"; value = $firstSourceText },
      @{ label = "Current source"; value = $currentSourceText },
      @{ label = "Release year"; value = $releaseText },
      @{ label = "Event note"; value = $eventText }
    ) | ForEach-Object {
@"
                <li><span>$($_.label)</span><span>$([System.Net.WebUtility]::HtmlEncode([string]$_.value))</span></li>
"@
    }

    $originDetailCards = foreach ($source in @($originSummary.sources | Select-Object -First 4)) {
      $sourceMeta = @()
      if (-not [string]::IsNullOrWhiteSpace($source.cost)) { $sourceMeta += $source.cost }
      if (-not [string]::IsNullOrWhiteSpace($source.petRarity)) {
        $rarityLabel = if ([string]$source.sourceType -eq "Egg") { "$($source.petRarity) hatch" } else { "$($source.petRarity) pet" }
        $sourceMeta += $rarityLabel
      }
      if (-not [string]::IsNullOrWhiteSpace($source.rarityBand)) { $sourceMeta += $source.rarityBand }
      $detailText = if ($sourceMeta.Count -gt 0) { $sourceMeta -join " - " } else { "Origin details audited from the Patch pet-origin dataset." }
      $footerBits = @()
      if (-not [string]::IsNullOrWhiteSpace($source.retired)) { $footerBits += "Retired $($source.retired)" }
      if (-not [string]::IsNullOrWhiteSpace($source.eventContext)) { $footerBits += $source.eventContext }
      if (-not [string]::IsNullOrWhiteSpace($source.notes)) { $footerBits += $source.notes }
      $footerText = if ($footerBits.Count -gt 0) { $footerBits -join " - " } else { "Audited source status: $($source.statusLabel)." }
@"
            <article class="card">
              <h3>$(HtmlEncode $source.sourceName)</h3>
              <p><strong>$(HtmlEncode $source.statusLabel)</strong>$(if (-not [string]::IsNullOrWhiteSpace($source.released)) { " - Released $(HtmlEncode $source.released)" })</p>
              <p>$(HtmlEncode $detailText)</p>
              <p>$(HtmlEncode $footerText)</p>
            </article>
"@
    }
    $originIntro = "These release and source notes come from The Patch's audited pet-origin dataset. We only publish this section when the source trail is confirmed."
  } else {
    $originSnapshotRows = @(
@"
                <li><span>Origin status</span><span>Audit still in progress</span></li>
"@,
@"
                <li><span>Release year</span><span>Pending confirmation</span></li>
"@,
@"
                <li><span>Event note</span><span>Pending confirmation</span></li>
"@,
@"
                <li><span>Source count</span><span>No audited source published yet</span></li>
"@
    )
    $originDetailCards = @(
@"
            <article class="card">
              <h3>Origin audit still in progress</h3>
              <p>The Patch has current value lanes for $(HtmlEncode $pet.name), but we have not yet published a fully confirmed release/source trail for this pet.</p>
              <p>We only surface egg, event, and release details here after they line up with the audited pet-origin dataset used elsewhere on the site.</p>
            </article>
"@
    )
    $originIntro = "This page already has current value lanes. The extra release and source details will appear here once the audited origin pass is complete for this pet."
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
$($heroMetricRows -join "`n")
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
      <div class="shell detail-grid">
        <section class="tool-card stack detail-main">
          <div class="section-head">
            <div>
              <h2>Audited pet details</h2>
              <p class="intro-copy">$(HtmlEncode $originIntro)</p>
            </div>
          </div>
          <div class="card-grid detail-card-grid">
$($originDetailCards -join "`r`n")
          </div>
        </section>
        <aside class="tool-card stack detail-sidebar">
          <div>
            <h2>Origin snapshot</h2>
            <p class="micro-copy">Release dates, source types, and event notes only show up here when the pet's origin has been confirmed in the local audited dataset.</p>
          </div>
          <ul class="mini-list variant-list">
$($originSnapshotRows -join "`r`n")
          </ul>
          <div class="stack-actions">
            <a class="pill-link" href="/articles/adopt-me-egg-guide.html">Open egg guide</a>
            <a class="pill-link" href="/articles/adopt-me-pet-encyclopedia.html">Browse pet encyclopedia</a>
            <a class="pill-link" href="/pet-value-calculator.html">Run trade calculator</a>
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
    origin = $originSummary
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
