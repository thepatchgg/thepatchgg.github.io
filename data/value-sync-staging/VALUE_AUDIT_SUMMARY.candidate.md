# Value Audit Summary

- Date: 2026-10-16
- Source refresh: fresh
- Mode: audit-only
- Scope: Adopt Me trade calculator long-tail pet values
- Reference source: adoptmevalues.app values index
- Legacy calculator catalog: 722 pets
- Benchmark/editorial pets currently handled outside the override layer: 101
- Comparable non-benchmark pet coverage in this run: 645
- Non-benchmark pets matched to public tracker feed: 636
- Non-benchmark pets manually resolved: 9
- Non-benchmark pets still unmatched: 0
- Current production comparable non-benchmark coverage: 634

## What Changed

- The calculator override layer was refreshed from the latest available tracker source.
- Tracker-backed lanes now update the broad long-tail value catalog without overwriting the editorial benchmark layer.
- Manual edge-case mappings remain in place for pets that do not map cleanly to the public tracker feed.
- Coverage should be judged against the current non-benchmark split, not older override totals from before the benchmark library expanded.
- The detailed calculator audit lives in data/adopt-me-calculator-audit-report.md.

## Benchmark Review Queue

These benchmark pets still deserve human review before any editorial benchmark change:

| Pet | Patch default | Tracker FR | Delta % |
| --- | ---: | ---: | ---: |
| Undead Jousting Horse | 19 | 90 | -78.9% |
| Werewolf | 8.25 | 36 | -77.1% |
| Frostbite Bear | 9 | 35 | -74.3% |
| Cerberus | 1.6 | 5.45 | -70.6% |
| Silverback Gorilla | 5.45 | 16.25 | -66.5% |
| Blazing Lion | 77 | 201 | -61.7% |
| Fairy Bat Dragon | 12.5 | 32.5 | -61.5% |
| Black-Chested Pheasant | 8 | 18.5 | -56.8% |

## Recommendation

- Do not auto-update benchmark pets from this workflow.
- Cross-check benchmark and spotlight pets against a second market reference before changing any live value file.
- If audit-only mode was used, review the candidate files in data/value-sync-staging before publishing.
- Only publish calculator override changes after QA passes and the conflict queue looks acceptable.
- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer.
