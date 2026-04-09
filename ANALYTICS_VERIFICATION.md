# Analytics Verification Guide

Use this before removing draft status. The goal is to confirm the new event wiring is visible in GA realtime or debug tooling.

## Events to verify

- `homepage_cta_click`
- `parent_cta_click`
- `tool_interaction`
- `watchlist_updated`
- `inventory_updated`
- `newsletter_submit`
- `newsletter_invalid`
- `newsletter_success`
- `outbound_click`

## Suggested test path

1. Open the homepage
2. Click a hero CTA
3. Submit an invalid newsletter email
4. Submit a valid newsletter email
5. Open the trade calculator and interact with both sides
6. Open market movers and toggle a watch button
7. Open inventory planner and save a short inventory
8. Open the parent guide and click a CTA
9. Click an outbound link such as the repo or Substack link

## Expected outcome

- Events appear with the expected names
- Page path is populated
- Tool interactions are attributed to the correct surface
- Newsletter events show the expected location tags

## If an event is missing

- Reproduce the action once more
- Confirm the page includes `assets/js/adopt-analytics.js`
- Confirm the browser is not blocking analytics requests
- Record the issue in the manual QA report before merge
