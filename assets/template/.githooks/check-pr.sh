#!/usr/bin/env bash
# CI gate: re-runs every local rule on the pull request, so --no-verify cannot skip them.
# Usage: check-pr.sh [base-ref]     (needs full history: fetch-depth 0)
set -uo pipefail
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$dir/config.sh"

base="${1:-origin/${BASE_BRANCH}}"
branch="${GITHUB_HEAD_REF:-$(git rev-parse --abbrev-ref HEAD)}"
status=0
tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT

git rev-parse -q --verify "${base}^{commit}" >/dev/null || { echo "base ref '$base' not found; fetch full history" >&2; exit 1; }

re="^(${BRANCH_PREFIXES})/[a-z0-9][a-z0-9._-]*$"
[[ "$branch" =~ $re ]] || { echo "branch '$branch' does not match <prefix>/<issue>-<description>" >&2; status=1; }

for sha in $(git rev-list --no-merges "${base}..HEAD"); do
  short="${sha:0:8}"
  count="$(git diff-tree --no-commit-id --name-only -r -M "$sha" | wc -l | tr -d ' ')"
  (( count == 1 )) || { echo "$short: touches $count files; one file per commit" >&2; status=1; }
  git log -1 --format=%B "$sha" > "$tmp"
  "$dir/validate-message.sh" "$tmp" 2> >(sed "s/^/$short: /" >&2) || status=1
done
exit $status
