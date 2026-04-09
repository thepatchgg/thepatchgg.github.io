# QA Runbook

This runbook is for local release verification only. It does not mean the branch is ready to merge by itself.

## 1. Start a local preview

From the repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-preview.ps1
```

Default preview URL:

```text
http://127.0.0.1:4173/
```

To stop it:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\stop-preview.ps1
```

## 2. Run automated checks

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\qa-site.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\qa-release.ps1
```

## 3. Capture baseline screenshots

With the preview server running:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\capture-release-screens.ps1
```

That will create desktop and mobile screenshots for the highest-risk pages in:

```text
qa-screenshots/
```

Note:

- screenshot capture is a best-effort helper
- if the local browser environment blocks headless screenshots, continue with the rest of the manual QA pass in a normal browser session

## 4. Manual visual review order

Review these first:

1. `/`
2. `/pet-value-calculator.html`
3. `/neon-calculator.html`
4. `/egg-value-calculator.html`
5. `/market-movers.html`
6. `/inventory-planner.html`
7. `/articles/adopt-me-pet-value-list-2026.html`
8. `/pets/`
9. `/pets/bat-dragon.html`

## 5. Manual functional checks

- Newsletter opens the Substack flow on the homepage and guides hub
- Value list variant selector changes values
- Trade calculator updates verdict when both sides change
- Neon calculator updates for target and lane changes
- Egg calculator updates for egg and hatch-count changes
- Watchlist buttons persist across page refresh
- Inventory planner saves and clears correctly

## 6. Analytics checks

Before merge, verify these in GA realtime or debug tooling:

- `homepage_cta_click`
- `parent_cta_click`
- `tool_interaction`
- `watchlist_updated`
- `inventory_updated`
- `newsletter_submit`
- `newsletter_invalid`
- `newsletter_success`
- `outbound_click`

## 7. Final docs to review

- `PRE_MERGE_CHECKLIST.md`
- `RELEASE_NOTES_DRAFT.md`
- `PR_BODY_DRAFT.md`
- `MANUAL_QA_REPORT_TEMPLATE.md`
- `ANALYTICS_VERIFICATION.md`
- `MERGE_DAY_RUNBOOK.md`
- `POST_MERGE_SMOKE_TEST.md`

## 8. Release snapshot

To print the current branch QA state:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\release-status.ps1
```

## 9. CI expectation

The branch should also pass the GitHub Actions workflow:

```text
Site QA
```

Keep the PR in draft until the checklist is manually signed off.
