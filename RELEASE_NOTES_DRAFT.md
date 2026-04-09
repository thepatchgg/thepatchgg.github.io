# Release Notes Draft

This draft is for PR cleanup and release prep. It does not mean the branch is approved to merge.

## Proposed PR title

Release-ready Adopt Me tool rebuild with shared data, benchmark pages, retention, and trust surfaces

## Proposed summary

This branch turns The Patch from a collection of inconsistent standalone pages into a more unified Adopt Me product surface.

### Core rebuild

- Replaces conflicting homepage, value list, and trade calculator logic with one shared value dataset
- Rebuilds the Neon calculator around shared variant-aware values
- Adds a benchmark egg value calculator using structured egg data

### Product and retention

- Adds market movers, inventory planner, watchlist persistence, recent pet tracking, and benchmark pet pages
- Launches a benchmark pet directory and shared pet-page generation flow

### Trust and content cleanup

- Rebuilds the Adopt Me hub, trust pages, parent guide, editorial policy, privacy policy, and advertising policy
- Cleans archive/event pages so historical content is marked as archive content instead of current guidance
- Removes older placeholder patterns and encoding issues from the active surfaces

### QA and operations

- Adds automated site QA and release QA scripts
- Adds a documented pre-merge checklist for manual signoff
- Adds structured metadata and stronger sitemap coverage across the rewritten pages

## Manual signoff still required

- Desktop visual QA
- Mobile visual QA
- Newsletter smoke test
- Calculator smoke test
- Analytics event verification

## Recommended merge note

Keep the PR in draft until the manual signoff checklist in `PRE_MERGE_CHECKLIST.md` is complete.

## Companion files

- `PR_BODY_DRAFT.md`
- `MANUAL_QA_REPORT_TEMPLATE.md`
- `QA_RUNBOOK.md`
