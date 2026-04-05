Help me follow my git workflow for this task. The rules are:

## Branching
- Always work on a new branch, never commit directly to `main`
- Branch names: short and descriptive (e.g. `add-waitlist-admin-view`)

## Commit Messages
Every commit must have three parts — no exceptions:
1. **Title** — imperative mood, max 80 characters (e.g. `Add hidden admin route to view waitlist signups`)
2. **Context** — what the situation was before this change
3. **Why** — the reason this change was necessary

Never include a `Co-Authored-By` trailer in any commit message.

## Before Pushing for CI
Squash all commits on the branch down to one:
```bash
git rebase -i main   # squash everything into one commit with the final message
git push --force-with-lease origin <branch>
```

## Watching CI
Wait for all checks to pass on the PR before merging.

## Merging
Fast-forward merge only, then clean up:
```bash
git checkout main
git merge --ff-only <branch>
git push origin main
git branch -d <branch>
git push origin --delete <branch>
```

## Deploy to Staging
To spin up a staging environment, include `[staging]` in a commit message on a branch with an open PR against `main`:
```bash
git commit --allow-empty -m "Deploy to staging for testing [staging]"
git push
```
Staging is ephemeral — it is automatically destroyed when the PR merges to `main`.

---

Based on the current state of the branch and what I'm working on, guide me through whichever step is next.
