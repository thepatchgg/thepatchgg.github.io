# Value Audit Summary

- Date: 2026-06-17
- Source refresh: fresh
- Mode: production refresh
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
- After manual review, the editorial benchmark layer was aligned to the same June 17 tracker lanes for all matched benchmark pets.
- Manual edge-case mappings remain in place for pets that do not map cleanly to the public tracker feed.
- Coverage should be judged against the current non-benchmark split, not older override totals from before the benchmark library expanded.
- The detailed calculator audit lives in data/adopt-me-calculator-audit-report.md.

## Benchmark Review Queue

No benchmark divergence rows were produced in the latest audit.

## Recommendation

- Do not auto-update benchmark pets from this workflow without review.
- Cross-check benchmark and spotlight pets against a second market reference before changing any high-stakes value file when sources disagree materially.
- If audit-only mode was used, review the candidate files in data/value-sync-staging before publishing.
- Only publish calculator override changes after QA passes and the conflict queue looks acceptable.
- Keep the current hybrid model: editorial anchors in the benchmark layer, tracker-backed long tail in the calculator override layer.
