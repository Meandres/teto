#!/usr/bin/env bash
# agent-run.sh <task-name> <scratch-dir> <prompt>
# Runs claude -p in the scratch dir with a wallclock + cost cap, logs to DB,
# prints the response text on stdout and a JSON summary on stderr line prefixed
# with "SUMMARY:".

set -euo pipefail

TASK="$1"
SCRATCH="$2"
PROMPT="$3"

DB="${AGENT_DB:-$HOME/agent-runs/agent-log.sqlite}"
TIMEOUT_SEC="${AGENT_TIMEOUT:-1800}"
COST_CAP_USD="${AGENT_COST_CAP:-2.0}"

mkdir -p "$SCRATCH"
cd "$SCRATCH"

started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
started_epoch="$(date +%s)"

# Run claude with structured output. --continue preserves history per-dir.
# Returns a JSON object with total_cost_usd, usage, and text fields.
raw_out="$(mktemp)"
status="success"
set +e
timeout "$TIMEOUT_SEC" claude -p "$PROMPT" \
  --continue \
  --output-format json \
  --dangerously-skip-permissions \
  > "$raw_out" 2>&1
rc=$?
set -e
[ $rc -eq 124 ] && status="timeout"
[ $rc -ne 0 ] && [ $rc -ne 124 ] && status="error"

finished_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Parse the structured output. Falls back gracefully if claude emitted plain text.
if jq -e . "$raw_out" >/dev/null 2>&1; then
  cost="$(jq -r '.total_cost_usd // 0' "$raw_out")"
  in_tok="$(jq -r '.usage.input_tokens // 0' "$raw_out")"
  out_tok="$(jq -r '.usage.output_tokens // 0' "$raw_out")"
  cache_tok="$(jq -r '.usage.cache_read_input_tokens // 0' "$raw_out")"
  text="$(jq -r '.result // .text // .content // empty' "$raw_out")"
else
  cost=0; in_tok=0; out_tok=0; cache_tok=0
  text="$(cat "$raw_out")"
fi

# Enforce cost cap post-hoc (per-run; a budgetary signal not a hard cutoff).
if awk -v c="$cost" -v cap="$COST_CAP_USD" 'BEGIN { exit !(c > cap) }'; then
  status="cost-exceeded"
fi

sqlite3 "$DB" <<SQL
INSERT INTO runs (task, started_at, finished_at, input_tokens, output_tokens, cache_read_tokens, cost_usd, status, notes)
VALUES (
  '$(printf %s "$TASK" | sed "s/'/''/g")',
  '$started_at',
  '$finished_at',
  $in_tok,
  $out_tok,
  $cache_tok,
  $cost,
  '$status',
  '$(printf %s "$SCRATCH" | sed "s/'/''/g")'
);
SQL

printf '%s\n' "$text"
printf 'SUMMARY:{"task":"%s","status":"%s","cost_usd":%s,"input_tokens":%s,"output_tokens":%s}\n' \
  "$TASK" "$status" "$cost" "$in_tok" "$out_tok" >&2

rm -f "$raw_out"
