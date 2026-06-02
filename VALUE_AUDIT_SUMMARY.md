# Value Audit Summary

- Date: 2026-06-02
- Source refresh: cached fallback
- Mode: production refresh
- Scope: Adopt Me trade calculator long-tail pet values
- Reference source: adoptmevalues.app values index
- Local calculator coverage: 731 pets
- Benchmark/editorial pets currently handled outside the override layer: 101
- Comparable non-benchmark pet coverage in this run: 630
- Non-benchmark pets matched to public tracker feed: 619
- Non-benchmark pets manually resolved: 11
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
| Dragonfruit Fox | 4.7 | 4.45 | 5.6% |
| Siamese Cat | 19 | 20 | -5% |
| Papa Moose | 7 | 6.75 | 3.7% |
| Field Mouse | 7.75 | 7.5 | 3.3% |
| Werewolf | 9.75 | 10 | -2.5% |
| Goose | 28 | 28.5 | -1.8% |
| Undead Jousting Horse | 21 | 21.25 | -1.2% |
| Bat Dragon | 794 | 800 | -0.8% |

## Recommendation

- Do not auto-update benchmark pets from this workflow.
- Cross-check benchmark and spotlight pets against a second market reference before changing any live value file.
- If audit-only mode was used, review the candidate files in data/value-sync-staging before publishing.
- Only publish calculator override changes after QA passes and the conflict queue looks acceptable.
- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer.
