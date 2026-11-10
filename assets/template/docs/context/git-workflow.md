# Git Workflow

How to branch and commit.

<!-- FILL INSTRUCTIONS (delete this block when done)
- A human fills the Settings table. The AI never chooses or changes the commit style.
- Commit style here must match COMMIT_STYLE in `.githooks/config`.
- Delete the row of the commit style you did not choose from "Subject line". Add no sections. Max 80 lines.
-->

## Settings

Set by a human. If any value is blank, stop and ask. Do not choose one.

| Setting | Value |
|---|---|
| Base branch | {main} |
| Commit style | {conventional or gitmoji} |
| Merge method | {rebase or merge commit} |

## Branches

- Create a branch before the first change. Never commit to the base branch.
- Branch from the latest base branch.
- One task per branch. Do not reuse a branch for a second task.
- Name it `<prefix>/<issue>-<short-description>`, lowercase with hyphens.

| Work | Prefix | Example |
|---|---|---|
| New capability | `feature/` | `feature/142-password-reset` |
| Defect | `fix/` | `fix/157-duplicate-invoice` |
| Urgent production defect | `hotfix/` | `hotfix/160-login-crash` |
| Restructure, no behavior change | `refactor/` | `refactor/163-split-billing-service` |
| Tests only | `test/` | `test/171-reset-token-expiry` |
| Documentation only | `docs/` | `docs/175-api-errors` |
| Tooling, config, dependencies | `chore/` | `chore/180-upgrade-linter` |

## Commits

- One file per commit. A rename counts as one file.
- Stage by path: `git add <path>`. Never `git add .` or `git add -A`.
- Commit only files the task changed.
- Commit in dependency order: definitions, then logic, then callers, then tests.

## Message format

```
<subject>

<body>

Refs: #<issue>
```

### Subject line

States what changed in this file. Imperative mood, max 72 characters, no trailing period.

| Style | Format | Example |
|---|---|---|
| conventional | `type(scope): summary` | `feat(auth): add reset token generator` |
| gitmoji | `<gitmoji> summary` | `✨ add reset token generator` |

| Change | conventional | gitmoji |
|---|---|---|
| New capability | `feat` | ✨ |
| Defect fix | `fix` | 🐛 |
| Restructure, no behavior change | `refactor` | ♻️ |
| Tests | `test` | ✅ |
| Documentation | `docs` | 📝 |
| Performance | `perf` | ⚡️ |
| Tooling, config, dependencies | `chore` | 🔧 |

### Body

One to three lines stating how this file's change contributes to the feature or fix.

| Write | Do not write |
|---|---|
| `Issues single-use tokens so the reset endpoint can verify email links.` | `Updated token.ts` |
| `Retries reused the request id, so the gateway billed twice.` | `Fixed bug after debugging and running tests` |

## Never

- Add AI or tool attribution: no `Co-Authored-By` for a tool, no "Generated with", no tool names or signatures.
- Use `--no-verify`, force push, or rewrite pushed commits.
- Merge. Open a pull request and stop.