# AI-Assisted Dev Workflow

A drop-in set of rules, templates, and checks that keeps AI coding agents inside your project's standards.

AI agents write verbose code, edit files they were not asked to touch, break project structure, patch symptoms, and read things they should not. Telling them not to is not enough, because an agent can ignore instructions. This kit pairs every instruction with a check the agent cannot skip.

## How it works

| Layer | What it is | What it does |
|---|---|---|
| Instructions | Markdown files in `docs/context/` | Tell agents and people how to work in this project |
| Local checks | Git hooks in `.githooks/` | Reject commits that break the branch and commit rules |
| Remote checks | A GitHub Actions workflow and `CODEOWNERS` | Re-run the rules on every pull request and require owner review |
| Agent limits | `.claude/settings.json` | Block Claude Code from reading secrets, editing protected files, or leaving the project folder |

The instructions say what to do. The other three layers catch it when they are ignored.

## What gets enforced

| Rule | Enforced by |
|---|---|
| Work happens on a typed branch (`feature/`, `fix/`, `chore/`, ...) | `pre-commit` hook, CI |
| One file per commit | `pre-commit` hook, CI |
| Commit message follows the style you chose (conventional or gitmoji shortcodes) | `commit-msg` hook, CI |
| Every commit explains how the change contributes to the feature or fix | `commit-msg` hook, CI |
| No AI attribution in commits | `commit-msg` hook, CI, Claude Code setting |
| Agents cannot read secrets | Claude Code permissions and sandbox |
| Agents cannot edit context files, hooks, or CI config | Claude Code permissions and sandbox, `CODEOWNERS` |
| Agents cannot read or write outside the project folder | Claude Code permissions |
| Scratch files stay out of commits | `.gitignore` (`.workspace/`) |

Everything else in the context files (code quality, architecture, UI rules) is guidance until you add a linter, test, or CI check for it. See [Limits](#limits).

## What gets installed

```
your-project/
├─ AGENTS.md                      entry point: tells agents which files to read
├─ .gitignore                     ignores secrets and .workspace/
├─ .gitattributes                 keeps hook files on LF line endings
├─ .claude/settings.json          Claude Code permissions and sandbox
├─ .githooks/
│  ├─ config.sh                   your choices: commit style, base branch, allowed prefixes
│  ├─ pre-commit                  branch name, one file per commit
│  ├─ commit-msg                  message format, no AI attribution
│  ├─ validate-message.sh         shared message check
│  └─ check-pr.sh                 runs all rules over a pull request
├─ .github/
│  ├─ CODEOWNERS                  owner review for the kit's files
│  └─ workflows/commit-rules.yml  CI check
└─ docs/
   ├─ progress-tracker.md         what changed in the project, one line per task
   └─ context/
      ├─ ai-workflow-rules.md     how to work
      ├─ project-overview.md      what to build and what not to build
      ├─ architecture.md          the design pattern and where files go
      ├─ code-standards.md        how code must be written
      ├─ git-workflow.md          how to branch and commit
      └─ ui-context.md            how interfaces must look and behave
```

Each context file covers one subject and is written as instructions, not description.

## Requirements

- git
- bash. On Windows, use Git Bash, which ships with Git for Windows.
- Optional: Claude Code, for `.claude/settings.json`. Its sandbox needs `bubblewrap` and `socat` on Linux, and WSL2 on Windows.
- Optional: GitHub, for the CI workflow and `CODEOWNERS`.

## Setup

### 1. Install into your project

```bash
git clone https://github.com/meltus-bwire/ai-assisted-dev-workflow.git
bash ai-assisted-dev-workflow/install.sh --dry-run /path/to/project   # preview, changes nothing
bash ai-assisted-dev-workflow/install.sh /path/to/project
```

The installer is safe to run on an existing project. See [What the installer does to existing files](#what-the-installer-does-to-existing-files).

### 2. Commit the kit

Do this before turning the rules on, because this commit contains many files.

```bash
cd /path/to/project
git checkout -b chore/add-ai-assisted-dev-workflow
git add .
git update-index --chmod=+x .githooks/pre-commit .githooks/commit-msg .githooks/validate-message.sh .githooks/check-pr.sh
git commit -m "chore: add AI-assisted dev workflow"
```

The `update-index` line marks the hooks as executable for Linux and macOS clones. Open a pull request and merge it.

### 3. Make your choices

These are decisions for a person. Agents are told to stop and ask if they are blank.

| Choice | Where |
|---|---|
| Commit style: `conventional` or `gitmoji` | `COMMIT_STYLE` in `.githooks/config.sh`, and the Settings table in `docs/context/git-workflow.md` |
| Design pattern, e.g. MVC | Pattern table in `docs/context/architecture.md` |
| Owner of the protected files | Replace `@your-handle` in `.github/CODEOWNERS` |
| Secret paths and allowed network domains | `.claude/settings.json` |

Until `COMMIT_STYLE` is set, the hooks reject every commit.

### 4. Fill in the context files

Each template has a comment block at the top with fill instructions. Write `project-overview.md` yourself. For the others, have your agent draft one file per session and review it:

```
Populate docs/context/<file> from its template. Read the repository first.
Follow the fill instructions in the template's comment block.
Output only the file contents.
```

Delete the comment block once a file is filled. `ai-workflow-rules.md` is mostly pre-written and only needs paths and commands.

### 5. Turn on the hooks

Each person runs this once per clone:

```bash
git config core.hooksPath .githooks
```

If the installer reported Husky, pre-commit, Lefthook, or custom hooks, skip this and call the kit from your existing hooks instead:

```bash
bash .githooks/pre-commit        # in your pre-commit hook
bash .githooks/commit-msg "$1"   # in your commit-msg hook
```

### 6. Turn on the remote checks

In your GitHub repository settings, protect the base branch:

- Require a pull request before merging.
- Require the `commit-rules` status check.
- Require review from code owners.

Local hooks can be skipped with `--no-verify`. These settings are what make the rules binding.

## Commit format

```
<subject>

<how this file's change contributes to the feature or fix>

Refs: #<issue>
```

| Style | Subject | Example |
|---|---|---|
| conventional | `type(scope): summary` | `feat(auth): add reset token generator` |
| gitmoji | `:code: summary` | `:sparkles: add reset token generator` |

Gitmoji uses shortcodes only, from the list in `GITMOJI_CODES`. The full mapping is in `docs/context/git-workflow.md`.

## What the installer does to existing files

| Situation | Action |
|---|---|
| File does not exist | Added |
| A context file, `settings.json`, `CODEOWNERS`, or `config.sh` already exists | Kept as is and listed for you to merge by hand |
| `AGENTS.md` or `CLAUDE.md` already exists | One marked block appended at the end, once |
| `.gitignore` or `.gitattributes` already exists | Missing lines appended |
| A hook script or the CI workflow differs from the kit | Kept, or replaced with `--update` |
| Husky, pre-commit, Lefthook, or custom hooks are present | Left alone; the installer prints how to call the kit from them |

It never turns the hooks on and never deletes or overwrites a file you already have.

## Customizing

| To change | Edit |
|---|---|
| Allowed branch prefixes | `BRANCH_PREFIXES` in `.githooks/config.sh` |
| Allowed commit types | `COMMIT_TYPES` in `.githooks/config.sh` |
| Allowed gitmoji codes | `GITMOJI_CODES` in `.githooks/config.sh` and the table in `git-workflow.md` |
| Subject length | `SUBJECT_MAX` in `.githooks/config.sh` |
| Base branch | `BASE_BRANCH` in `.githooks/config.sh` |
| One file per commit | Remove the file-count check in `.githooks/pre-commit` and `.githooks/check-pr.sh` |
| Protected paths and secrets | `permissions.deny` and `sandbox` in `.claude/settings.json` |

Keep `config.sh` and `git-workflow.md` in agreement: the first is what the hooks check, the second is what the agent reads.

## Updating

```bash
git -C ai-assisted-dev-workflow pull
bash ai-assisted-dev-workflow/install.sh --update /path/to/project
```

`--update` replaces only the hook scripts and the CI workflow. Context files, `config.sh`, and settings are never replaced.

## Using other AI tools

The context files, hooks, and CI checks work with any agent. Point your tool at `AGENTS.md`, or copy its block into the file your tool loads. `.claude/settings.json` applies to Claude Code only; for other tools, set equivalent file and command restrictions in that tool, or run the agent in a container that mounts only the project.

## Troubleshooting

| Symptom | Cause and fix |
|---|---|
| `commit rejected: COMMIT_STYLE is not set` | Set `COMMIT_STYLE` in `.githooks/config.sh`. |
| `commit rejected: branch 'main' is not allowed` | Create a branch first, e.g. `git checkout -b feature/12-short-name`. |
| `commit rejected: 2 files staged` | Stage and commit one file at a time with `git add <path>`. |
| Hooks do not run | Run `git config core.hooksPath .githooks`. On Linux or macOS, also check the files are executable. |
| `$'\r': command not found` | A hook file has Windows line endings. Confirm `.gitattributes` is committed, then run `git add --renormalize .githooks`. |
| Claude Code exits at startup | The sandbox cannot start. Install `bubblewrap` and `socat` on Linux, or use WSL2 on Windows. |
| The CI check fails on the pull request that adds the kit | Expected: that commit has many files. Merge it before making the check required. |

## Limits

- Hooks check the form of a commit, not whether its message is true. Review still matters.
- Local hooks can be bypassed. The CI check and branch protection are the real gate.
- Code quality, architecture, and UI rules are instructions only. Back them with a formatter, linter, type checker, tests, and an import-boundary check in CI.
- One file per commit means a change that spans files leaves intermediate commits that may not build. Run CI on the branch head, and use rebase or merge commits rather than squash if you want the per-file history kept.
- Anyone with write access can edit `.claude/settings.json`. `CODEOWNERS` review is what protects it.

## Removing

```bash
git config --unset core.hooksPath
```

Then delete the files listed under [What gets installed](#what-gets-installed) and the marked block in `AGENTS.md`.

## License

{Add a license before publishing.}