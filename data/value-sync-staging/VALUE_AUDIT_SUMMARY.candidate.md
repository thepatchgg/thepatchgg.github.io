# Value Audit Summary

- Date: 2026-11-08
- Source refresh: cached
- Mode: audit-only
- Scope: Adopt Me trade calculator long-tail pet values
- Reference source: adoptmevalues.app values index
- Legacy calculator catalog: 738 pets
- Benchmark/editorial pets currently handled outside the override layer: 101
- Comparable non-benchmark pet coverage in this run: 661
- Non-benchmark pets matched to public tracker feed: 652
- Non-benchmark pets manually resolved: 9
- Non-benchmark pets still unmatched: 0
- Current production comparable non-benchmark coverage: 645

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
| Frostbite Bear | 9 | 41 | -78% |
| Candicorn | 6.45 | 21.5 | -70% |
| Werewolf | 8.25 | 26 | -68.3% |
| Velocirooster | 10 | 6 | 66.7% |
| Fairy Bat Dragon | 12.5 | 33.5 | -62.7% |
| Undead Jousting Horse | 19 | 50 | -62% |
| Frost Unicorn | 10.25 | 26 | -60.6% |
| Chocolate Chip Bat Dragon | 25.25 | 62.5 | -59.6% |

## Recommendation

- Do not auto-update benchmark pets from this workflow.
- Cross-check benchmark and spotlight pets against a second market reference before changing any live value file.
- If audit-only mode was used, review the candidate files in data/value-sync-staging before publishing.
- Only publish calculator override changes after QA passes and the conflict queue looks acceptable.
- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer.
