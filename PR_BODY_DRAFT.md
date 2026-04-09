# PR Body Draft

## Suggested title

Release-ready Adopt Me tool rebuild with shared data, benchmark pages, retention, and trust surfaces

## Suggested body

## Summary

- rebuild the core Adopt Me value experience around one shared benchmark dataset
- replace conflicting calculator and value-page logic with shared JS/CSS/data foundations
- add benchmark pet pages, retention tools, egg coverage, trust pages, and pre-merge QA tooling

## What Changed

### Core value system

- added a canonical value dataset in `data/adopt-me-values.json`
- rebuilt the homepage, value list, trade calculator, and neon calculator around shared data
- added shared helper assets in `assets/js/adopt-values.js` and `assets/css/adopt-tools.css`

### Product surfaces

- added benchmark pet pages and a benchmark library under `pets/`
- added market movers, inventory planner, and egg value calculator
- added shared retention features for watchlists, recent pets, and saved inventory

### Trust and content cleanup

- rebuilt the Adopt Me hub and key evergreen guides
- converted older event pages into clearly labeled archives
- added methodology, corrections, changelog, editorial policy, parent guide, privacy, and advertising pages
- removed lingering placeholder patterns and encoding issues on the active surfaces

### QA and release prep

- added automated site QA and release QA scripts
- added a local preview workflow and screenshot capture tooling
- added a pre-merge checklist, QA runbook, release notes draft, and manual QA report template

## Manual Signoff Still Required

- desktop visual QA
- mobile visual QA
- newsletter smoke test
- calculator smoke test
- analytics event verification

## Notes

- this PR is intentionally still draft
- nothing in this branch is live until it is merged into `main`
- the pre-merge signoff should follow `PRE_MERGE_CHECKLIST.md`
