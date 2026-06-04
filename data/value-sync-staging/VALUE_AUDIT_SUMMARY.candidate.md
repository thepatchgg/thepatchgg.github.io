# Value Audit Summary

- Date: 2026-06-04
- Source refresh: fresh
- Mode: audit-only
- Scope: Adopt Me trade calculator long-tail pet values
- Reference source: adoptmevalues.app values index
- Local calculator coverage: 731 pets
- Benchmark/editorial pets currently handled outside the override layer: 101
- Comparable non-benchmark pet coverage in this run: 630
- Non-benchmark pets matched to public tracker feed: 621
- Non-benchmark pets manually resolved: 9
- Non-benchmark pets still unmatched: 0
- Current production comparable non-benchmark coverage: 630

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
| Siamese Cat | 19 | 26 | -26.9% |
| Goose | 28 | 32 | -12.5% |
| Werewolf | 9.75 | 11.1 | -12.2% |
| Black Panther | 1.85 | 2 | -7.5% |
| Chicken | 1.85 | 2 | -7.5% |
| Rhino | 1.95 | 2.1 | -7.1% |
| Capybara | 1.95 | 2.1 | -7.1% |
| Bat Dragon | 794 | 852 | -6.8% |

## Recommendation

- Do not auto-update benchmark pets from this workflow.
- Cross-check benchmark and spotlight pets against a second market reference before changing any live value file.
- If audit-only mode was used, review the candidate files in data/value-sync-staging before publishing.
- Only publish calculator override changes after QA passes and the conflict queue looks acceptable.
- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer.
