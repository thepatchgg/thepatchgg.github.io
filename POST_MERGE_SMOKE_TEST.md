# Post-Merge Smoke Test

Run this after the PR is merged and GitHub Pages has had time to update.

## Public URLs to check first

- [ ] `https://thepatchgg.github.io/`
- [ ] `https://thepatchgg.github.io/pet-value-calculator.html`
- [ ] `https://thepatchgg.github.io/neon-calculator.html`
- [ ] `https://thepatchgg.github.io/egg-value-calculator.html`
- [ ] `https://thepatchgg.github.io/market-movers.html`
- [ ] `https://thepatchgg.github.io/inventory-planner.html`
- [ ] `https://thepatchgg.github.io/articles/adopt-me-pet-value-list-2026.html`
- [ ] `https://thepatchgg.github.io/pets/`
- [ ] `https://thepatchgg.github.io/pets/bat-dragon.html`
- [ ] `https://thepatchgg.github.io/privacy.html`
- [ ] `https://thepatchgg.github.io/advertising.html`

## Functional checks

- [ ] Homepage newsletter opens the expected Substack flow
- [ ] Trade calculator updates totals and verdict
- [ ] Neon calculator updates when target and lane change
- [ ] Egg calculator updates when egg and hatch count change
- [ ] Watchlist still works in the public build
- [ ] Inventory planner still saves and clears correctly

## Search and metadata checks

- [ ] Sitemap is reachable
- [ ] Favicon loads
- [ ] Social metadata appears on key pages
- [ ] New trust pages resolve publicly

## Deployment notes

- GitHub Pages deployments can lag briefly after merge
- If a page looks stale, hard refresh and retry before assuming deploy failure
