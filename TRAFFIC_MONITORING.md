# Traffic Monitoring Playbook

Use this file to keep traffic, indexing, and content-growth work organized over time.

This document is written for both:

- humans reviewing the site each week
- AI coding agents such as Claude that may help analyze traffic data and suggest next steps

If you are an AI agent, read this file before making SEO, traffic, or content-prioritization recommendations.

## Purpose

The goal is not to chase vanity traffic.

The goal is to:

1. get important pages indexed
2. identify pages and queries that are starting to work
3. improve CTR on pages already getting impressions
4. expand clusters that show real traction
5. avoid random publishing that is not backed by search demand or product value

## Data Sources

Use these sources in roughly this order:

1. Google Search Console
2. Google Analytics 4
3. Site knowledge from the repo
4. Current search landscape / competitor review if needed

If Search Console and GA disagree, trust Search Console for Google search queries and click/impression data.

## Core Reports To Check

### Search Console

- `Performance -> Search results`
- `Page indexing`
- `Sitemaps`

Primary dimensions:

- queries
- pages
- countries
- devices

Primary metrics:

- clicks
- impressions
- CTR
- average position

### Google Analytics

- `Reports -> Search Console -> Landing pages`
- `Reports -> Search Console -> Queries`
- `Reports -> Acquisition -> Traffic acquisition`
- `Reports -> Engagement -> Landing page`

Primary metrics:

- users
- sessions
- engaged sessions
- average engagement time
- conversions or meaningful events

## Priority Pages

These are the pages to check first unless a newer update page is clearly trending.

### Core tools

- `/`
- `/pet-value-calculator.html`
- `/neon-calculator.html`
- `/egg-value-calculator.html`
- `/market-movers.html`

### Core guides

- `/articles/adopt-me-pet-value-list-2026.html`
- `/articles/adopt-me-egg-guide.html`
- `/articles/adopt-me-pet-encyclopedia.html`
- `/articles/adopt-me-trading-guide-2026.html`

### Egg landing pages

- `/articles/adopt-me-basic-egg-guide.html`
- `/articles/adopt-me-crystal-egg-guide.html`
- `/articles/adopt-me-endangered-egg-guide.html`
- `/articles/adopt-me-aztec-egg-guide.html`
- `/articles/adopt-me-royal-aztec-egg-guide.html`
- `/articles/adopt-me-moon-egg-guide.html`

### Key pet pages

- `/pets/bat-dragon.html`
- `/pets/shadow-dragon.html`
- `/pets/frost-dragon.html`
- `/pets/giraffe.html`
- `/pets/evil-unicorn.html`
- `/pets/cow.html`
- `/pets/turtle.html`
- `/pets/unicorn.html`
- `/pets/dragon.html`

## Weekly Review Cadence

Run this review once per week.

### Step 1: Check indexing health

Review:

- new pages indexed vs not indexed
- pages discovered but not indexed
- pages excluded unexpectedly

Actions:

- if an important page is not indexed, request indexing in Search Console
- if several similar pages are not indexed, improve internal linking before publishing more pages in that cluster

### Step 2: Check top pages by search impressions

Ask:

- which pages are getting impressions?
- which new pages started appearing?
- which pages lost visibility?

Actions:

- high impressions means Google is testing the page
- those pages deserve title/meta review before publishing random new ones

### Step 3: Check CTR opportunities

Look for pages with:

- meaningful impressions
- low CTR
- decent average position

Default rule:

- if a page has impressions and weak CTR, improve its title/meta first

### Step 4: Check query opportunities

Review:

- queries bringing clicks
- queries bringing impressions but no clicks
- unexpected queries worth building pages around

Actions:

- if one egg or pet query starts showing up repeatedly, build adjacent pages in that same cluster
- if a query mismatch appears, align the page title and intro with that actual search intent

### Step 5: Check landing-page quality in GA

Review:

- engaged sessions
- engagement time
- bounce-like behavior
- whether users move deeper into calculators or pet pages

Actions:

- if a page gets traffic but no onward clicks, strengthen internal links and CTA placement
- if a page gets traffic and drives deeper exploration, expand that cluster

## Decision Rules

Use these rules consistently.

### If impressions are high but CTR is low

Likely fix:

- rewrite title
- rewrite meta description
- tighten first paragraph so it matches the query better

### If clicks are low and impressions are low

Likely fix:

- improve internal linking
- request indexing
- publish more content around the same topic cluster

### If position is improving but traffic is still small

Likely fix:

- leave the page alone unless the title/snippet is weak
- avoid rewriting a page that Google is still learning

### If one page starts winning

Likely fix:

- build nearby pages immediately
- add stronger homepage and in-article links to that winner

### If a page gets organic traffic but weak engagement

Likely fix:

- improve the opening section
- clarify the answer earlier
- add obvious next-click links to calculators or related pages

## Content Expansion Rules

Do not publish randomly.

Expand only from one of these signals:

1. Search Console query demand
2. repeated internal-site interest
3. current Adopt Me update relevance
4. proven traffic from a nearby page in the same cluster

Best clusters to expand next when they show signs of traction:

- egg pages
- pet value pages
- weekly update pages
- update-specific trade pages
- calculator-adjacent help pages

## Rules For Claude And Other Agents

If you are an AI agent working on traffic or analytics:

- do not invent traffic numbers
- do not claim ranking gains without data
- do not suggest broad rewrites just because a page is not ranking yet
- prefer specific next actions tied to actual metrics
- preserve the existing Patch visual identity while improving traffic surfaces
- do not add internal/SEO strategy language to public pages
- keep recommendations in plain user-facing English, not marketing jargon

When summarizing traffic:

- separate facts from recommendations
- mention dates
- mention whether the conclusion came from Search Console, GA, or inference

## Monthly Questions

Once per month, answer these:

1. Which pages got the most search impressions?
2. Which pages got the most actual organic clicks?
3. Which page clusters are growing fastest?
4. Which pages have the best CTR?
5. Which pages are underperforming despite ranking?
6. What 5 pages should we improve next?
7. What 5 pages should we publish next?

## Suggested Weekly Output Format

Use this exact structure when logging a review.

### Week Of

`YYYY-MM-DD`

### Search Console Highlights

- top query gains:
- top page gains:
- low-CTR opportunities:
- indexing issues:

### GA Highlights

- strongest landing pages:
- weak-engagement landing pages:
- pages sending users into calculators:

### Actions This Week

1. 
2. 
3. 

### Pages To Watch Next Week

- 
- 
- 

## Running Log

### Week Of 2026-04-10

- Search Console and GA linkage was completed.
- New egg landing pages were published and added to the sitemap.
- Next review should focus on whether the new egg pages start receiving impressions and whether the homepage sends users into them.
