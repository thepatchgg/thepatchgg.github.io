# October 16 Release Review

- User explicitly requested news review, approved-process price checks, publication, and live validation.
- Latest official news: https://www.playadopt.me/news/halloween-stitches-spotlight-notes (October 16, 2026). Ghost Gallery and Hauntlet Returns were already published.
- News scope: Stitches' Spotlight guide, four official local pet images, four pet pages, catalog and encyclopedia support, pending calculator entries, homepage/hub routing, and sitemap.
- Fresh tracker source successfully retrieved on October 16: https://www.adoptmevalues.app/values. The old parser rejected the changed packed format; the repaired parser follows the site's public unpackPets decoder and validates its schema.
- Final audit: 795 tracker pet rows; 636 non-benchmark tracker matches; nine existing manual resolutions; zero unmatched; 645 overrides, with no loss of the 634 previously published overrides.
- All twelve former launch projections now have audited tracker coverage (Bison, ten Fairytale Egg pets, Ballet Swan). Eleven enter the primary override layer for the first time; Bison already existed there. The obsolete projection overlay is emptied to avoid conflicting values.
- Picker checks cover every published override, fresh matrices taking precedence over stale projections, profile value alignment, and pending new-pet images.
- Benchmark/editorial JSON is unchanged. Benchmark differences remain in the candidate audit report for manual editorial review; no benchmark or spotlight value is promoted from a single-source comparison.

## Cross-source spot checks

- Silverback Gorilla: AdoptMeValues and Elvebredd both show 15.25 for Normal No Potion. AdoptMeValues shows 16.25 for Normal Fly Ride. The Patch benchmark remains 4.75 No Potion / 5.45 Fly Ride pending full variant review.
  - https://www.adoptmevalues.app/values/silverback-gorilla
  - https://elvebredd.com/pets/silverback-gorilla
- Bat Dragon: Elvebredd shows 1,000 for Normal Fly Ride, agreeing with the fetched AdoptMeValues packed row. The Patch benchmark remains unchanged pending full variant review.
  - https://elvebredd.com/pets/bat-dragon?variant=111
  - https://www.adoptmevalues.app/values
- Copycat is listed by Elvebredd on release day, but the audited AdoptMeValues feed has no row yet. All four October 16 pets remain unpriced; official Candy Corn/Robux purchase costs are published separately.
  - https://elvebredd.com/pets/copycat

## Priority benchmark queue

Undead Jousting Horse, Werewolf, Frostbite Bear, Cerberus, Silverback Gorilla, Blazing Lion, Fairy Bat Dragon, and Black-Chested Pheasant lead the fresh divergence report. See the candidate report for the full 25-row queue.
