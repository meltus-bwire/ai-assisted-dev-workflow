#!/usr/bin/env bash
# Validates one commit message. Usage: validate-message.sh <message-file>
set -euo pipefail
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$dir/config.sh"

fail() { echo "commit rejected: $1" >&2; exit 1; }

msg="$(grep -v '^#' "$1" || true)"
subject="$(printf '%s\n' "$msg" | sed -n '1p')"
separator="$(printf '%s\n' "$msg" | sed -n '2p')"
body="$(printf '%s\n' "$msg" | sed -n '3,$p' | grep -viE '^(refs|closes|fixes):' | tr -d '[:space:]' || true)"

[[ "$subject" == Merge\ * ]] && exit 0

case "${COMMIT_STYLE:-}" in
  conventional)
    re="^(${COMMIT_TYPES})(\([a-z0-9._/-]+\))?!?: [^[:space:]]"
    [[ "$subject" =~ $re ]] || fail "subject must be 'type(scope): summary'. Types: ${COMMIT_TYPES//|/, }."
    ;;
  gitmoji)
    re="^:(${GITMOJI_CODES}): [^[:space:]]"
    [[ "$subject" =~ $re ]] || fail "subject must be ':code: summary', e.g. ':sparkles: add reset token generator'. Codes: ${GITMOJI_CODES//|/, }."
    ;;
  *)
    fail "COMMIT_STYLE is not set in .githooks/config.sh. A human must set it to 'conventional' or 'gitmoji'."
    ;;
esac

(( ${#subject} <= SUBJECT_MAX )) || fail "subject is ${#subject} characters; max is ${SUBJECT_MAX}."
[[ -z "$separator" ]] || fail "line 2 must be blank."
[[ -n "$body" ]] || fail "body is required: state how this file's change contributes to the feature or fix."

attribution='co-authored-by:.*(claude|anthropic|copilot|cursor|openai|chatgpt|codex|gemini|devin|aider|\[bot\])|generated (with|by)|noreply@anthropic\.com|🤖'
if printf '%s\n' "$msg" | grep -qiE "$attribution"; then
  fail "remove AI or tool attribution from the message."
fi
