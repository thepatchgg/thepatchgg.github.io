# Value Audit Summary

- Date: 2026-05-09
- Source refresh: fresh
- Mode: audit-only
- Scope: Adopt Me trade calculator long-tail pet values
- Reference source: adoptmevalues.app values index
- Local calculator coverage: 719 pets
- Benchmark/editorial pets currently handled outside the override layer: 101
- Comparable non-benchmark pet coverage in this run: 618
- Non-benchmark pets matched to public tracker feed: 606
- Non-benchmark pets manually resolved: 12
- Non-benchmark pets still unmatched: 0
- Current production comparable non-benchmark coverage: 618

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
| Jekyll Hydra | 19.25 | 40 | -51.9% |
| Mermicorn | 16.75 | 34 | -50.7% |
| Velocirooster | 14.75 | 10 | 47.5% |
| Haetae | 67 | 127 | -47.2% |
| Undead Jousting Horse | 11.5 | 19 | -39.5% |
| Silverback Gorilla | 7.5 | 5.45 | 37.6% |
| Unicorn | 2.5 | 1.9 | 31.6% |
| Dragonfruit Fox | 6.5 | 4.95 | 31.3% |

## Recommendation

- Do not auto-update benchmark pets from this workflow.
- Cross-check benchmark and spotlight pets against a second market reference before changing any live value file.
- If audit-only mode was used, review the candidate files in data/value-sync-staging before publishing.
- Only publish calculator override changes after QA passes and the conflict queue looks acceptable.
- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer.
