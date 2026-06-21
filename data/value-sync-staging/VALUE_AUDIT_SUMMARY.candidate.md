# Value Audit Summary

- Date: 2026-06-21
- Source refresh: fresh
- Mode: audit-only
- Scope: Adopt Me trade calculator long-tail pet values
- Reference source: adoptmevalues.app values index
- Local calculator coverage: 733 pets
- Benchmark/editorial pets currently handled outside the override layer: 101
- Comparable non-benchmark pet coverage in this run: 632
- Non-benchmark pets matched to public tracker feed: 623
- Non-benchmark pets manually resolved: 9
- Non-benchmark pets still unmatched: 0
- Current production comparable non-benchmark coverage: 632

## What Changed

- The calculator override layer was refreshed from the latest available tracker source.
- Tracker-backed lanes now update the broad long-tail value catalog.
- Manual edge-case mappings remain in place for pets that do not map cleanly to the public tracker feed.
- Coverage should be judged against the current non-benchmark split, not older override totals from before the benchmark library expanded.
- The detailed calculator audit lives in data/adopt-me-calculator-audit-report.md.

## Benchmark Review Queue

These benchmark pets still deserve human review before any editorial benchmark change:

| Pet | Patch default | Tracker FR | Delta % |
| --- | ---: | ---: | ---: |
| Orchid Butterfly | 80 | 104 | -23.1% |
| Werewolf | 21 | 27 | -22.2% |
| Frost Unicorn | 10.5 | 12.25 | -14.3% |
| Undead Jousting Horse | 36 | 41 | -12.2% |
| Jekyll Hydra | 42 | 45 | -6.7% |
| Frostbite Bear | 8 | 7.5 | 6.7% |
| Diamond Butterfly | 51 | 54 | -5.6% |
| Jellyfish | 9 | 9.5 | -5.3% |

## Recommendation

- Publish benchmark pet changes only when the benchmark sync and divergence guardrails pass.
- Cross-check benchmark and spotlight pets against a second market reference when sources disagree materially.
- If audit-only mode was used, review the candidate files in data/value-sync-staging before publishing.
- Only publish calculator override changes after QA passes and the conflict queue is clear.
- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer.
