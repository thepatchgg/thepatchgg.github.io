# New Pet Release Playbook

Use this playbook when Adopt Me ships a brand-new pet and we need to update the site quickly without inventing values.

This is written for both humans and AI agents such as Claude.

## Goal

Cover a newly released pet across the right site surfaces in the right order:

1. official update coverage
2. discovery surfaces
3. pet catalog and pet-page support
4. value surfaces only when value confidence is good enough

## Core Principle

Do not treat `content coverage` and `value coverage` as the same thing.

A new pet can be:

- fully covered in an update article
- promoted on the homepage and guide hub
- added to the pet encyclopedia and pet-page system

before it is safe to add a live calculator value.

If the market is too fresh, the value layer should stay pending.

## Source Order

For a new pet release, use sources in this order:

1. official Adopt Me news post on `playadopt.me/news`
2. official `playadopt.me/discover/pets` entry if live
3. Adopt Me Wiki for follow-up origin/background details
4. public value trackers only after the pet starts appearing there

## Coverage Tiers

### Tier 1: Same-Day Required

These should happen as soon as a new pet is officially confirmed:

- update/article coverage
- homepage tile or hero routing if it is the main live update
- `adopt-me.html` hub placement if it is the main live update
- coverage audit run

### Tier 2: Early Structured Coverage

These should happen once the pet name, rarity, image path, and origin are clear enough:

- `data/adopt-me-pet-catalog.json`
- `data/adopt-me-pet-pages.json` via generator
- `/pets/<slug>.html`
- pet encyclopedia coverage
- sitemap refresh
- local image asset if available

### Tier 3: Value Coverage

Only do this when the market is real enough to support it:

- calculator layer
- benchmark/value list placement
- market movers
- comparison guides

If current public value sources disagree materially, keep the pet out of benchmark surfaces until reviewed.

## Files To Check

### Content and discovery

- `index.html`
- `adopt-me.html`
- `articles/`
- `sitemap.xml`

### Pet discovery and pet pages

- `data/adopt-me-pet-catalog.json`
- `data/adopt-me-pet-pages.json`
- `scripts/generate-adopt-pet-pages.ps1`
- `pets/`
- `articles/adopt-me-pet-encyclopedia.html`

### Value layers

- `data/adopt-me-values.json`
- `data/adopt-me-calculator-values.json`
- `data/adopt-me-calculator-overrides.json`
- `pet-value-calculator.html`

### Optional origin/history support

- `data/adopt-me-pet-origin-overrides.json`
- `data/adopt-me-audited-eggs.json`

## Release Checklist

### 1. Confirm the pet exists officially

- capture the official update name
- capture the exact pet name
- capture the release date
- capture rarity if published
- capture how it is obtained
- do not guess an end date or drop rate if Uplift did not publish one

### 2. Publish or draft the update article

- create the article first
- keep claims tied to official wording
- explain the pet in player-friendly language
- if the value is unknown, say the market is still forming instead of guessing

### 3. Promote the article in discovery surfaces

- homepage hero CTA if it is the main live update
- homepage latest update tiles
- `adopt-me.html` current rotation

### 4. Run the pet coverage audit

Run:

`powershell -ExecutionPolicy Bypass -File scripts/audit-new-pet-coverage.ps1 -PetNames "<Pet Name>"`

This checks whether the pet is present in:

- update articles
- homepage
- guide hub
- pet catalog
- legacy calculator dataset
- benchmark layer
- override layer
- pet-page dataset
- generated pet page
- local image assets

### 5. Decide whether the pet belongs in structured pet surfaces now

Add the pet to the pet catalog and pet-page system if:

- the name is final
- the rarity is clear enough
- the source/origin is understandable enough to describe honestly

If origin details are incomplete, use audit-pending wording rather than guessing.

### 6. Decide whether the pet belongs in value surfaces now

Add the pet to value surfaces only if:

- at least one reliable public value source has listed it
- the market is active enough to avoid fake precision
- benchmark placement is actually justified

If that threshold is not met:

- keep it out of the benchmark layer
- do not invent a calculator number
- mention in the article that values are still forming

## Decision Rules

### Safe to add immediately

- article coverage
- homepage and hub links
- pet encyclopedia/catalog entry
- pet page with audited or audit-pending origin context

### Needs more caution

- value list placement
- benchmark layer
- calculator values
- market movers placement

## QA

Before calling the work done, run:

- `powershell -ExecutionPolicy Bypass -File scripts/qa-site.ps1`
- `powershell -ExecutionPolicy Bypass -File scripts/qa-release.ps1`

Then manually spot-check:

- article page
- homepage
- `adopt-me.html`
- pet encyclopedia if the pet was added there
- pet page if one was created
- trade calculator only if the pet was added to value surfaces

## AI Agent Rules

If you are an AI agent:

- read `CLAUDE.md` first
- use this playbook for new pet release work
- do not invent values for a newly released pet
- do not assume a drop rate or event deadline unless officially published
- run the audit script before claiming the pet is covered across the site
- summarize which layer is complete:
  - article/discovery
  - pet discovery/page coverage
  - live value coverage

## Current Example

`Purrowl` is a good example of why this playbook exists:

- the article and discovery surfaces can be live immediately
- the pet may still be missing from catalog and calculator layers
- value coverage may need to wait until the market settles
