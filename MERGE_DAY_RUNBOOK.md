# Merge-Day Runbook

This runbook is for the final handoff from draft PR to merged PR. Do not use it until the manual QA and analytics checks are complete.

## 1. Confirm branch readiness

- Run `powershell -ExecutionPolicy Bypass -File .\scripts\release-status.ps1`
- Confirm the worktree is clean
- Confirm both QA scripts pass
- Confirm the manual QA report is filled out

## 2. Update PR metadata

Use `PR_BODY_DRAFT.md` as the source of truth.

- Update the PR title
- Replace the outdated PR summary/body
- Keep the PR in draft until the manual checklist is fully signed off

## 3. Final pre-ready checks

- Confirm GitHub Actions `Site QA` is passing
- Confirm analytics verification has been completed
- Confirm newsletter flow was smoke-tested
- Confirm desktop and mobile review notes are recorded

## 4. Remove draft status

Only after the above are complete:

- Mark the PR ready for review
- Re-check the diff one last time

## 5. Merge

- Merge into `main`
- Do not squash away the release-prep history unless you explicitly want that

## 6. Immediate post-merge checks

Follow `POST_MERGE_SMOKE_TEST.md`

## 7. Public verification

After GitHub Pages updates:

- Verify the homepage reflects the rebuilt version
- Verify a core calculator page
- Verify a benchmark pet page
- Verify the new trust/policy pages

## 8. If something is wrong

- Do not panic-merge more changes blindly
- Document the issue first
- Fix on a new branch or follow-up PR if the problem is not trivial
