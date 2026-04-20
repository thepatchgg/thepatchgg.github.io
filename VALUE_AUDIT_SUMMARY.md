# Value Audit Summary

- Date: 2026-04-19
- Source refresh: cached
- Mode: production refresh
- Scope: Adopt Me trade calculator long-tail pet values
- Reference source: adoptmevalues.app values index
- Local calculator coverage: 714 pets
- Benchmark/editorial pets currently handled outside the override layer: 101
- Comparable non-benchmark pet coverage in this run: 614
- Non-benchmark pets matched to public tracker feed: 602
- Non-benchmark pets manually resolved: 12
- Non-benchmark pets still unmatched: 0
- Current production comparable non-benchmark coverage: 614

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
| Candicorn | 7.75 | 7.75 | 0% |
| Cerberus | 1.65 | 1.65 | 0% |
| Chicken | 1.75 | 1.75 | 0% |
| Bush Elephant | 8.75 | 8.75 | 0% |
| Cabbit | 21.75 | 21.75 | 0% |
| Cactus Friend | 1.55 | 1.55 | 0% |
| Dragon | 1.1 | 1.1 | 0% |
| Dragonfruit Fox | 6.5 | 6.5 | 0% |

## Recommendation

- Do not auto-update benchmark pets from this workflow.
- Cross-check benchmark and spotlight pets against a second market reference before changing any live value file.
- If audit-only mode was used, review the candidate files in data/value-sync-staging before publishing.
- Only publish calculator override changes after QA passes and the conflict queue looks acceptable.
- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer.
