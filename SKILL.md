---
name: ai-assisted-dev-workflow
description: Sets up and maintains an enforceable workflow for AI coding agents in a git repository - context files (AGENTS.md, workflow rules, project overview, architecture, code standards, git workflow, UI context, progress tracker), git hooks, a CI check, CODEOWNERS, and Claude Code permission settings. Use this whenever the user wants guardrails or rules for AI-assisted development, wants to stop an agent editing files it should not touch, reading secrets, or working outside the project, wants to enforce branch naming, conventional or gitmoji commits, one file per commit, or no AI attribution, asks to create or fill in AGENTS.md, CLAUDE.md, or project context files, or is adopting AI coding agents in a new or existing project, even if they never name this workflow.
license: MIT. See LICENSE.txt.
compatibility: Needs git and bash (Git Bash on Windows). Installing into a project needs file and shell access to that repository.
---

# AI-Assisted Dev Workflow

Installs a set of instructions and checks into a project so that AI agents follow the project's standards, and so that it is caught when they do not.

The idea behind every step: an agent can ignore a written rule, so each rule that matters is paired with a check outside the agent (a git hook, a CI job, a permission setting). Your job is to install the pieces without disturbing what the project already has, get the human's decisions, and fill the templates from what is true in the repository.

## What is bundled

| Path | Use |
|---|---|
| `scripts/install.sh` | Copies the template into a project. Never overwrites an existing file. |
| `assets/template/` | The files that get installed. Do not edit these when installing; edit the copies in the project. |
| `references/guide.md` | Full guide: what each rule is enforced by, customizing, troubleshooting, limits. Read it when the user asks how something is enforced, wants to change a rule, or hits an error. |

## Setting up a project

### 1. Preview

Find the root of the user's git repository, then run a dry run and show the user what will happen:

```bash
bash <skill-dir>/scripts/install.sh --dry-run <project-root>
```

Existing projects often have their own `AGENTS.md`, hooks, or settings. The dry run shows which files will be added, which will be kept, and which get lines appended, so the user is not surprised.

### 2. Install

```bash
bash <skill-dir>/scripts/install.sh <project-root>
```

Relay the installer's "kept" list. Those are files the project already had; offer to merge the template's content into them, and make each merge only with the user's agreement.

The installer does not turn the hooks on. Leave it that way until step 6.

### 3. Get the human's decisions

Ask the user for these. Do not pick for them, even when one option looks obvious: they are project policy, the context files tell every agent to stop and ask when they are blank, and the hooks reject every commit until the commit style is set.

| Decision | Where it goes |
|---|---|
| Commit style: `conventional` or `gitmoji` (shortcodes such as `:sparkles:`) | `COMMIT_STYLE` in `.githooks/config.sh` and the Settings table in `docs/context/git-workflow.md` |
| Design pattern, e.g. MVC | Pattern table in `docs/context/architecture.md` |
| Base branch and merge method | `BASE_BRANCH` in `.githooks/config.sh`, Settings table in `git-workflow.md` |
| Who owns the protected files | Replace `@your-handle` in `.github/CODEOWNERS` |
| Secret file paths, secret environment variables, allowed network domains | `.claude/settings.json` |

For an existing codebase, look at the code first and say which pattern it already follows, then ask the user to confirm. Reporting what is there is useful; choosing is theirs.

### 4. Fill the context files

Each file in `docs/context/` has a comment block at the top with its own fill instructions. Follow that block. The rules common to all of them:

- Describe the repository as it is. Check every path, command, and version against the code or config before writing it.
- Where something is unknown, write `TODO(<owner>): <question>` rather than a guess. A wrong rule in these files misleads every later agent session.
- Write instructions, not descriptions, and stay under the file's line limit. Short files get followed; long ones get skimmed.
- Keep each file to its one subject. If a fact belongs in another file, put it there.
- Delete the comment block when the file is filled.

Work through them one at a time and show each to the user before moving on:

1. `project-overview.md` - draft from the README and docs; the user confirms every line, especially "Out of scope".
2. `architecture.md` - only after the pattern is decided.
3. `code-standards.md` - derive from linter, formatter, and type-checker configs and from the best existing code. Do not restate what a tool already enforces.
4. `git-workflow.md` - fill the Settings table from step 3 and delete the row for the commit style that was not chosen.
5. `ui-context.md` - only if the project has an interface; otherwise delete it and its row in `AGENTS.md`.
6. `ai-workflow-rules.md` - mostly pre-written; fill the protected paths and the verification commands.

Leave `docs/progress-tracker.md` empty apart from its rules.

### 5. Commit the kit

The first commit contains many files, which the hooks would reject, so it has to happen before they are turned on:

```bash
git checkout -b chore/add-ai-assisted-dev-workflow
git add .
git update-index --chmod=+x .githooks/pre-commit .githooks/commit-msg .githooks/validate-message.sh .githooks/check-pr.sh
git commit -m "chore: add AI-assisted dev workflow"
```

The `update-index` line records the hooks as executable so they run on Linux and macOS clones. Commit only when the user asks you to; otherwise give them the commands.

### 6. Turn the rules on

These change how the whole team works, so tell the user what each does and let them decide when:

- `git config core.hooksPath .githooks` turns on the local hooks, once per clone. If the installer reported Husky, pre-commit, Lefthook, or custom hooks, do not change `core.hooksPath`; add the two calls the installer printed to the existing hooks instead.
- On GitHub, protect the base branch: require a pull request, the `commit-rules` status check, and code-owner review. Local hooks can be skipped with `--no-verify`; this is what makes the rules binding.

Merge the pull request that adds the kit before making `commit-rules` required, because that pull request itself breaks the one-file rule.

## Working in a project that already has the workflow

If the repository has `docs/context/`, read the files `AGENTS.md` lists and follow them. In particular:

- When a hook rejects a commit, fix the commit. Do not use `--no-verify`, and do not edit `.githooks/`, `.claude/`, or `docs/context/` to get past it; those are the user's controls.
- Update `docs/progress-tracker.md` with outcomes only: one line per completed task, saying what the project now has. Not a log of what you ran or read.

## Updating an installed project

```bash
bash <skill-dir>/scripts/install.sh --update <project-root>
```

This replaces only the hook scripts and the CI workflow. The project's context files, `config.sh`, and settings are never replaced.

## Without access to the repository

If you cannot reach the user's files or run commands in their project (a plain chat session), do not describe the files from memory. Zip `scripts/install.sh` together with `assets/template/` (placed beside the script as `template/`) and `references/guide.md` (as `README.md`), give the user that archive, and point them to the Setup section of the guide.

## Reporting back

When you finish, tell the user briefly: what was added, what was kept and needs merging, which decisions are still blank, and the next step that is theirs to take.