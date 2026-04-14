# Pet Value Sync Process

Use this process to keep Adopt Me pet values refreshed twice a week without risking accidental bad benchmark edits.

This workflow is written for both humans and AI agents such as Claude.

## Goal

Refresh the tracker-backed long-tail value layer on a fixed schedule, generate an audit report, and surface the benchmark pets that still need human editorial review.

## Schedule

Run this process `2x per week`.

Recommended cadence:

- Tuesday morning
- Friday morning

## Source Of Truth Split

Do not blur these layers together:

- `data/adopt-me-values.json`
  Editorial benchmark layer for core anchor pets and main site surfaces.
- `data/adopt-me-calculator-overrides.json`
  Tracker-backed long-tail calculator override layer.
- `data/adopt-me-calculator-manual-mappings.json`
  Documented edge-case pet mappings.

## Main Command

Run:

`powershell -ExecutionPolicy Bypass -File scripts/refresh-pet-values.ps1 -AuditOnly`

What this does:

1. fetches the current Adopt Me Values index page when possible
2. falls back to the cached source if fetch fails
3. rebuilds candidate override data in `data/value-sync-staging`
4. rebuilds a candidate audit report in `data/value-sync-staging`
5. refreshes a candidate summary in `data/value-sync-staging`
6. runs `qa-site.ps1`
7. runs `qa-release.ps1`

## Production Update Rule

The recurring process should be treated as `audit-only` by default.

It should not automatically publish value changes.

Only promote candidate files into production after a human review.

## Safe Publishing Rule

Automatic refreshes may propose updates to the long-tail calculator layer.

They must **not** automatically rewrite the editorial benchmark layer in `data/adopt-me-values.json`, and they should not automatically overwrite the production override layer either unless a human explicitly approves it.

Reason:

- benchmark pets are trust anchors
- some intentional editorial differences should remain
- high-tier pets still need human review before benchmark changes go live

## What To Review After Each Run

Check:

- `data/value-sync-staging/VALUE_AUDIT_SUMMARY.candidate.md`
- `data/value-sync-staging/adopt-me-calculator-audit-report.candidate.md`
- git diff for:
  - `data/value-sync-staging/adopt-me-calculator-overrides.candidate.json`
  - `data/value-sync-staging/adopt-me-calculator-audit-report.candidate.md`
  - `data/value-sync-staging/VALUE_AUDIT_SUMMARY.candidate.md`

Pay special attention to benchmark review rows involving:

- Bat Dragon
- Shadow Dragon
- Owl
- Parrot
- Crow
- Unicorn
- Dragon
- Dragonfruit Fox
- Silverback Gorilla
- Cupid Dragon
- Jekyll Hydra

## Cross-Source Validation Rule

Before changing any benchmark pet or spotlight pet in production, confirm the move against at least two independent public market references.

Recommended minimum check:

1. Adopt Me Values
2. a second public market reference such as Elvebredd or a comparable live-trading tracker

If the sources disagree materially, do not auto-publish the change. Move it into a manual review queue instead.

## Publishing Guidance

If the reviewed candidate run only changes the long-tail calculator override layer and QA passes, those updates are usually safe to promote into production after review.

If the run suggests changing:

- `data/adopt-me-values.json`

stop and review the benchmark differences manually before publishing.

## AI Agent Rules

If you are an AI agent:

- read `CLAUDE.md` first
- use this file as the value-refresh playbook
- do not invent values
- do not auto-edit the benchmark layer without explicit confirmation
- do not promote audit-only candidate files into production without explicit confirmation
- summarize:
  - whether fetch used fresh or cached source
  - tracker match counts
  - manual resolution counts
  - unmatched counts
  - QA status
  - whether benchmark review is needed
