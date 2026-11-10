# AI Workflow Rules

How to work in this repository. Applies to AI agents and human collaborators.

<!-- FILL INSTRUCTIONS (delete this block when done)
- Most rules are pre-written. Fill only the {placeholders}.
- Take paths and commands from the repository (package scripts, Makefile, CI config). Do not invent them.
- Unknown value: write `TODO({owner}): {question}`. Do not guess.
- Add no sections. Max 90 lines.
-->

## 1. Before writing code

1. Read the context files listed in `AGENTS.md`.
2. State the task in one sentence and list the files you expect to change.
3. Wait for approval if the task: touches more than {5} files, adds a dependency, changes a public interface, changes the data schema, or is ambiguous.

## 2. Scope

- Change only the files the task requires.
- No unrequested refactors, renames, reformatting, or dependency upgrades. List them under "Noticed" in your report.
- Do not create, move, or delete directories or top-level files without approval.
- One task, one branch, one pull request. Follow `git-workflow.md`.

## 3. Access

| Rule | Paths / commands |
|---|---|
| Never read or print | `{.env*}`, `{secrets/}`, `{*.pem}`, `{path}` |
| Never edit | `{docs/context/* except progress-tracker.md}`, `{.github/}`, `{lockfiles by hand}`, `{migrations already applied}`, `{path}` |
| Never run | `git push --force`, `git commit --no-verify`, `{deploy command}`, `{destructive db command}`, `{command}` |
| Never commit to | `{main}` |

Use only data in the repository and the task. Do not call external services or fetch URLs not named in the task.

## 4. Making changes

- Search for existing code that does the job before writing new code.
- Fix the root cause. If you cannot find it, say so. Do not patch the symptom.
- Never make a check pass by disabling it: no lint suppressions, skipped tests, swallowed errors, or type escapes.
- Change a test only when the test is wrong. Say why.
- Deliver the smallest diff that completes the task.

## 5. Verify before reporting done

Run all of these. All must pass.

| Check | Command |
|---|---|
| Format | `{command}` |
| Lint | `{command}` |
| Types | `{command}` |
| Tests | `{command}` |
| Build | `{command}` |

- New behavior has a test. A bug fix has a test that fails without the fix.
- Never state that something works unless you ran it.

## 6. Stop and ask when

- A rule in any context file blocks the task.
- A check fails and the fix is outside the task's files.
- The same fix has failed twice.
- You need a file, credential, or command listed in section 3.

## 7. Report

End every task with this and nothing else:

```
Changed: {files}
Verified: {commands run and result}
Not verified: {what you could not run, or "none"}
Noticed: {out-of-scope problems, or "none"}
```

## 8. Context files

- Update `progress-tracker.md` at the end of each completed task, following its rules.
- Propose changes to any other context file in your report. Do not edit them.