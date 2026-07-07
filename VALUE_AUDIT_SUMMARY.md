# Value Audit Summary

- Date: 2026-07-07
- Source refresh: fresh
- Mode: production refresh
- Scope: Adopt Me trade calculator long-tail pet values
- Reference source: adoptmevalues.app values index
- Local calculator coverage: 746 pets
- Benchmark/editorial pets currently handled outside the override layer: 101
- Comparable non-benchmark pet coverage in this run: 645
- Non-benchmark pets matched to public tracker feed: 636
- Non-benchmark pets manually resolved: 9
- Market-forming pets pending tracker values: 0
- Non-benchmark pets still unmatched: 0
- Current production comparable non-benchmark coverage: 645

## What Changed

- The calculator override layer was refreshed from the latest available tracker source.
- Tracker-backed lanes now update the broad long-tail value catalog.
- Manual edge-case mappings remain in place for pets that do not map cleanly to the public tracker feed.
- Coverage should be judged against the current non-benchmark split, not older override totals from before the benchmark library expanded.
- The detailed calculator audit lives in data/adopt-me-calculator-audit-report.md.

## Benchmark Review Queue

No benchmark divergence rows were produced in the latest audit.

## Recommendation

- Publish benchmark pet changes only when the benchmark sync and divergence guardrails pass.
- Cross-check benchmark and spotlight pets against a second market reference when sources disagree materially.
- If audit-only mode was used, review the candidate files in data/value-sync-staging before publishing.
- Only publish calculator override changes after QA passes and the conflict queue is clear.
- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer.
