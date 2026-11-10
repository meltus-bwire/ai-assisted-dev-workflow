# Progress Tracker

Current state of the project. Read at the start of a task. Update at the end.

## Update rules

- Record what changed in the project, not what you did while working.
- Add an entry only for a task that is complete and passes all checks in `ai-workflow-rules.md`.
- One line per task, max 100 characters. State the outcome a user or developer now has.
- Edit only entries for your current task. Do not reword, reorder, or remove others' entries.
- Do not record: files read, commands run, attempts, debugging steps, reasoning, or file lists. Git holds those.
- Keep to the limits in each section. When Done exceeds 15 rows, delete the oldest.

| Write | Do not write |
|---|---|
| `Added password reset by email link` | `Read auth module, tried two approaches, fixed lint, ran tests` |
| `Fixed duplicate invoices on retry` | `Updated invoice.ts, retry.ts and 3 test files` |

## Now

Max 3. One owner each.

| Task | Owner | Ref |
|---|---|---|
| {task} | {name or agent} | {#issue} |

## Next

Max 5, in priority order. Humans set this list.

1. {task} ({#issue})

## Blocked

| Task | Blocked by | Needs |
|---|---|---|
| {task} | {cause} | {decision or action, and from whom} |

## Known issues

Confirmed defects not yet fixed. Max 10.

| Issue | Impact | Ref |
|---|---|---|
| {issue} | {who or what it affects} | {#issue} |

## Done

Newest first. Max 15.

| Date | Change | Ref |
|---|---|---|
| {YYYY-MM-DD} | {outcome} | {#PR} |
