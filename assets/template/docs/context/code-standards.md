# Code Standards

How code must be written.

<!-- FILL INSTRUCTIONS (delete this block when done)
- Derive rules from tool configs and from the best existing code. Verify each against the repository.
- If a formatter, linter, or type checker already enforces a rule, do not list it. Name the config file instead.
- Unknown value: write `TODO({owner}): {question}`. Do not guess.
- One rule per line, imperative, testable in review. No explanations.
- Adjust the pre-written rules to the project; delete those that do not apply. Add no sections. Max 90 lines.
-->

## Enforced by tooling

Do not restate, override, or suppress these.

| Tool | Config |
|---|---|
| {formatter} | `{path}` |
| {linter} | `{path}` |
| {type checker} | `{path}` |

## Reference code

Match these files when writing the same kind of code.

| Kind | Copy the pattern in |
|---|---|
| {e.g. Endpoint} | `{path}` |
| {e.g. Service} | `{path}` |
| {e.g. Component} | `{path}` |
| {e.g. Test} | `{path}` |

## Lean code

- Write only what the task needs. No speculative options, parameters, or abstractions.
- Add an abstraction on the third duplication, not before.
- Delete unused code. Do not comment it out.
- Prefer the standard library and existing dependencies over new code or new packages.
- One function, one job. Max {40} lines per function, {300} per file, {3} levels of nesting, {4} parameters.
- Return early instead of nesting.

## Naming

| Item | Convention | Example |
|---|---|---|
| Files | {convention} | `{example}` |
| Functions | {convention} | `{example}` |
| Types / classes | {convention} | `{example}` |
| Constants | {convention} | `{example}` |
| Tests | {convention} | `{example}` |

- Use glossary terms from `project-overview.md`.
- No abbreviations except: {id, url, ...}.

## Types and data

- {e.g. No `any`, no unchecked casts.}
- {e.g. Validate all external input at the boundary with `{library}`.}
- {e.g. Prefer immutable data.}

## Errors

- {e.g. Throw typed errors from `path`. Never throw strings.}
- Never swallow an error. Handle it or let it propagate.
- {e.g. Error messages state what failed and what input caused it. No secrets or personal data.}

## Comments

- Comment why, never what.
- No narration of changes ("added", "fixed", "updated"). That belongs in the commit message.
- No `TODO` without an issue reference: `TODO({#123})`.
- {e.g. Document every exported function with `{doc format}`.}

## Tests

- {e.g. Test file sits next to source: `x.ts` and `x.test.ts`.}
- Test behavior through public interfaces, not implementation details.
- One behavior per test. Name states the behavior.
- {e.g. Mock only external services.}
- {e.g. Coverage on changed lines: {80}% minimum.}

## Security

- No secrets, keys, or credentials in code, tests, logs, or comments.
- {e.g. Parameterized queries only.}
- {e.g. Never log personal data.}