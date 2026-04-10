# Value Audit Summary

- Date: 2026-04-09
- Scope: Adopt Me trade calculator long-tail pet values
- Reference source: locally cached public values index from `adoptmevalues.app`
- Local calculator coverage: 714 pets
- Non-benchmark pets in local calculator: 696
- Non-benchmark pets matched to public tracker feed: 684
- Non-benchmark pets manually resolved: 12
- Non-benchmark pets still unmatched: 0

## What Changed

- The calculator now keeps The Patch benchmark layer for the core anchor pets.
- A bulk override layer now supplies live tracker lanes for 684 non-benchmark pets.
- A manual edge-case layer now resolves the final 12 non-benchmark pets instead of leaving them stale or unmatched.
- The restored calculator potion row supports `No Pot`, `Fly`, `Ride`, and `Fly Ride`.
- Long-tail matched pets now use explicit stage and potion lanes instead of legacy flat multipliers.

## Biggest Remaining Benchmark Divergences

These are the largest differences still left after the April 9, 2026 benchmark review. The biggest low-tier misses were corrected first, and the main high-tier anchors were re-synced to current live page-level values where the potion, Neon, and Mega lanes had drifted.

| Pet | Patch default | Tracker FR | Delta % |
| --- | ---: | ---: | ---: |
| Blazing Lion | 48 | 52.5 | -8.6% |
| Kangaroo | 17 | 18.5 | -8.1% |
| Frost Dragon | 206 | 224 | -8.0% |
| Chocolate Chip Bat Dragon | 21.25 | 23 | -7.6% |
| Cow | 27 | 29 | -6.9% |
| Arctic Reindeer | 39 | 41.5 | -6.0% |

## Manual Edge-Case Resolutions

- Burtaur: forced to zero as a temporary April Fools pet.
- Pet Rock: forced to zero as a temporary non-tradable pet.
- Practice Dog: forced to zero because it is not part of the live tradable pet market.
- Pumpkin Pet: forced to zero as a temporary event pet rather than the tradable Pumpkin Friend.
- Scoob: forced to zero as a temporary non-tradable event pet.
- Dylan, Pistachio, and River: mapped to current Wrapped Doll pet values.
- Malayan Tapir: mapped to Malaysian Tapir.
- Mole Pet: mapped to Mole.
- Praying Mantis Pet: mapped to Praying Mantis.
- Weevil Pet: mapped to Weevil.

## Recommendation

- Keep the current hybrid model for launch: benchmark pets on The Patch values, long-tail pets on tracker-backed overrides, and edge cases on documented manual resolutions.
- Sync only the obvious low-tier benchmark misses to market consensus. Unicorn and Dragon were the clearest underpriced anchors and should be tightened first.
- The five major high-tier anchors reviewed in this pass now keep their Patch ordering while using fresher live per-pet variant lanes.
