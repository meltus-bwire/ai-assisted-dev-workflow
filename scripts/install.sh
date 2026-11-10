#!/usr/bin/env bash
# Installs the kit into an existing or new project. Never overwrites project files.
# Usage: install.sh [--dry-run] [--update] [target-dir]
#   --dry-run   show what would happen, change nothing
#   --update    also replace kit-owned scripts (hooks, CI workflow) with this kit's version
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kit="$here/template"
[[ -d "$kit" ]] || kit="$here/../assets/template"
[[ -d "$kit" ]] || { echo "template folder not found next to install.sh" >&2; exit 2; }
kit="$(cd "$kit" && pwd)"
dry=0; update=0; target="."
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry=1 ;;
    --update)  update=1 ;;
    -h|--help) sed -n '2,5p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "unknown option: $arg" >&2; exit 2 ;;
    *)  target="$arg" ;;
  esac
done
[[ -d "$target" ]] || { echo "not a directory: $target" >&2; exit 2; }
target="$(cd "$target" && pwd)"
[[ -e "$target/.git" ]] || { echo "$target is not the root of a git repository" >&2; exit 2; }

marker='ai-assisted-dev-workflow:start'
manual=()

is_managed()    { case "$1" in .githooks/config.sh) return 1 ;; .githooks/*|.github/workflows/commit-rules.yml) return 0 ;; *) return 1 ;; esac; }
is_line_merge() { case "$1" in .gitignore|.gitattributes) return 0 ;; *) return 1 ;; esac; }
say()  { printf '  %-10s %s\n' "$1" "$2"; }
run()  { (( dry )) || "$@"; }
put()  { run mkdir -p "$(dirname "$2")"; run cp "$1" "$2"; }

append_block() {  # append the kit's marked block to an existing entry file, once
  local dest="$1" rel="$2"
  if grep -q "$marker" "$dest"; then say unchanged "$rel"; return; fi
  if (( ! dry )); then { printf '\n'; cat "$kit/AGENTS.md"; } >> "$dest"; fi
  say appended "$rel (kit block added at the end)"
}

merge_lines() {  # add only the lines the project file does not already have
  local src="$1" dest="$2" rel="$3" added=0 line
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" ]] && continue
    grep -qxF -- "$line" "$dest" && continue
    if (( ! dry )); then
      [[ -z "$(tail -c1 "$dest")" ]] || printf '\n' >> "$dest"
      printf '%s\n' "$line" >> "$dest"
    fi
    added=$((added + 1))
  done < "$src"
  if (( added )); then say merged "$rel ($added lines added)"; else say unchanged "$rel"; fi
}

echo "Installing into $target$( (( dry )) && echo '  (dry run)')"
while IFS= read -r rel; do
  src="$kit/$rel"; dest="$target/$rel"
  if [[ ! -e "$dest" ]]; then put "$src" "$dest"; say added "$rel"
  elif cmp -s "$src" "$dest"; then say unchanged "$rel"
  elif [[ "$rel" == AGENTS.md ]]; then append_block "$dest" "$rel"
  elif is_line_merge "$rel"; then merge_lines "$src" "$dest" "$rel"
  elif is_managed "$rel"; then
    if (( update )); then put "$src" "$dest"; say updated "$rel"
    else say kept "$rel (differs from kit; use --update to replace)"; fi
  else say kept "$rel (yours; not touched)"; manual+=("$rel")
  fi
done < <(cd "$kit" && find . -type f | sed 's|^\./||' | LC_ALL=C sort)

[[ -f "$target/CLAUDE.md" ]] && append_block "$target/CLAUDE.md" "CLAUDE.md"
run chmod +x "$target"/.githooks/pre-commit "$target"/.githooks/commit-msg \
             "$target"/.githooks/validate-message.sh "$target"/.githooks/check-pr.sh 2>/dev/null || true

# Hooks are never switched on here, so nothing changes until you choose to.
other=""
current="$(git -C "$target" config --get core.hooksPath || true)"
[[ -n "$current" && "$current" != ".githooks" ]] && other="core.hooksPath is already '$current'"
[[ -d "$target/.husky" ]] && other="${other:+$other; }Husky found"
[[ -f "$target/.pre-commit-config.yaml" ]] && other="${other:+$other; }pre-commit framework found"
[[ -f "$target/lefthook.yml" || -f "$target/lefthook.yaml" ]] && other="${other:+$other; }Lefthook found"
if [[ -z "$current" ]] && find "$target/.git/hooks" -maxdepth 1 -type f ! -name '*.sample' 2>/dev/null | grep -q .; then
  other="${other:+$other; }custom hooks found in .git/hooks"
fi

echo
if (( ${#manual[@]} )); then
  echo "Kept your version of these. Compare with the kit's copy in $kit and merge by hand:"
  printf '  - %s\n' "${manual[@]}"
  echo
fi
echo "Next steps:"
echo "  1. Set COMMIT_STYLE in .githooks/config.sh and fill the templates in docs/context/."
echo "  2. Replace @your-handle in .github/CODEOWNERS."
echo "  3. Commit the kit files and merge them before turning the rules on."
if [[ -n "$other" ]]; then
  echo "  4. Existing hook setup detected ($other)."
  echo "     Do not change core.hooksPath. Call the kit from your existing hooks instead:"
  echo "       pre-commit:  bash .githooks/pre-commit"
  echo "       commit-msg:  bash .githooks/commit-msg \"\$1\""
else
  echo "  4. Turn the hooks on (each clone, once):  git config core.hooksPath .githooks"
fi
echo "  5. Make 'commit-rules' a required status check on the base branch."
