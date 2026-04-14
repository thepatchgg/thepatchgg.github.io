# Value Audit Summary

- Date: 2026-04-13
- Source refresh: cached
- Mode: audit-only
- Scope: Adopt Me trade calculator long-tail pet values
- Reference source: adoptmevalues.app values index
- Local calculator coverage: 714 pets
- Benchmark/editorial pets currently handled outside the override layer: 101
- Comparable non-benchmark pet coverage in this run: 613
- Non-benchmark pets matched to public tracker feed: 601
- Non-benchmark pets manually resolved: 12
- Non-benchmark pets still unmatched: 0
- Current production comparable non-benchmark coverage: 613
- Legacy production override entries now superseded by the benchmark layer: 83

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
| Parrot | 122.5 | 149 | -17.8% |
| Shadow Dragon | 372 | 419 | -11.2% |
| Owl | 167 | 187 | -10.7% |
| Bat Dragon | 578 | 647 | -10.7% |
| Crow | 117 | 129 | -9.3% |
| Unicorn | 2.5 | 2.75 | -9.1% |
| Blazing Lion | 48 | 52.5 | -8.6% |
| Kangaroo | 17 | 18.5 | -8.1% |

## Recommendation

- Do not auto-update benchmark pets from this workflow.
- Cross-check benchmark and spotlight pets against a second market reference before changing any live value file.
- If audit-only mode was used, review the candidate files in data/value-sync-staging before publishing.
- Only publish calculator override changes after QA passes and the conflict queue looks acceptable.
- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer.
