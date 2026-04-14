# Value Audit Summary

- Date: 2026-04-13
- Source refresh: cached
- Mode: audit-only
- Scope: Adopt Me trade calculator long-tail pet values
- Reference source: adoptmevalues.app values index
- Local calculator coverage: 714 pets
- Non-benchmark pets matched to public tracker feed: 601
- Non-benchmark pets manually resolved: 12
- Non-benchmark pets still unmatched: 0

## What Changed

- The calculator override layer was refreshed from the latest available tracker source.
- Tracker-backed lanes now update the broad long-tail value catalog without overwriting the editorial benchmark layer.
- Manual edge-case mappings remain in place for pets that do not map cleanly to the public tracker feed.
- The detailed calculator audit lives in data/adopt-me-calculator-audit-report.md.

## Benchmark Review Queue

These benchmark pets still deserve human review before any editorial benchmark change:

| Pet | Patch default | Tracker FR | Delta % |
| --- | ---: | ---: | ---: |
| Parrot | 122.5 | 152 | -19.4% |
| Silverback Gorilla | 10.75 | 9.25 | 16.2% |
| Dragonfruit Fox | 8.5 | 7.5 | 13.3% |
| Shadow Dragon | 372 | 428 | -13.1% |
| Bat Dragon | 578 | 664 | -13% |
| Owl | 167 | 192 | -13% |
| Crow | 117 | 132 | -11.4% |
| Kangaroo | 17 | 19 | -10.5% |

## Recommendation

- Do not auto-update benchmark pets from this workflow.
- Cross-check benchmark and spotlight pets against a second market reference before changing any live value file.
- If audit-only mode was used, review the candidate files in data/value-sync-staging before publishing.
- Only publish calculator override changes after QA passes and the conflict queue looks acceptable.
- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer.
