# Value Audit Summary

- Date: 2026-08-07
- Source refresh: fresh
- Mode: production refresh
- Scope: Adopt Me trade calculator long-tail pet values
- Reference source: adoptmevalues.app values index
- Local calculator coverage: 735 pets
- Benchmark/editorial pets currently handled outside the override layer: 101
- Comparable non-benchmark pet coverage in this run: 634
- Non-benchmark pets matched to public tracker feed: 625
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
| Undead Jousting Horse | 21 | 58.5 | -64.1% |
| Werewolf | 9.75 | 24 | -59.4% |
| Sugar Glider | 13.25 | 27 | -50.9% |
| Cerberus | 1.6 | 3.2 | -50% |
| Frostbite Bear | 8.25 | 16.5 | -50% |
| Candicorn | 5.7 | 10.5 | -45.7% |
| Blazing Lion | 81 | 147 | -44.9% |
| Orchid Butterfly | 59 | 105 | -43.8% |

## Recommendation

- Do not auto-update benchmark pets from this workflow.
- Cross-check benchmark and spotlight pets against a second market reference before changing any live value file.
- If audit-only mode was used, review the candidate files in data/value-sync-staging before publishing.
- Only publish calculator override changes after QA passes and the conflict queue looks acceptable.
- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer.
