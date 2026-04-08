#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$BASE_DIR/config/mcporter.json"
SERVER_BIN="$BASE_DIR/.venv/bin/mcp-server-weibo"
GLOBAL_NPM_PREFIX="${GLOBAL_NPM_PREFIX:-/root/.openclaw/workspace/.npm-global}"
GLOBAL_MCPORTER_BIN="$GLOBAL_NPM_PREFIX/bin/mcporter"
RUN_SMOKE="${RUN_SMOKE:-1}"

log() { printf '[weibo] %s\n' "$*"; }
fail() { printf '[weibo] ERROR: %s\n' "$*" >&2; exit 1; }

resolve_mcporter() {
  if [ -n "${MCPORTER_BIN:-}" ] && [ -x "${MCPORTER_BIN}" ]; then
    printf '%s\n' "$MCPORTER_BIN"
    return 0
  fi
  if command -v mcporter >/dev/null 2>&1; then
    command -v mcporter
    return 0
  fi
  for candidate in \
    "$GLOBAL_MCPORTER_BIN" \
    "/root/.openclaw/workspace/.npm-global/bin/mcporter"
  do
    if [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

smoke_test() {
  log "running smoke test: weibo.get_trendings limit:1"
  (
    cd "$BASE_DIR"
    "$MCPORTER_BIN" call weibo.get_trendings limit:1 >/tmp/weibo-skill-check-smoke.json
  ) || fail "smoke test failed"
  log "smoke test: OK"
}

log "base dir: $BASE_DIR"
[ -f "$CONFIG_FILE" ] || fail "local mcporter config not found: $CONFIG_FILE"
log "local mcporter config: OK"
[ -x "$SERVER_BIN" ] || fail "server binary not found: $SERVER_BIN"
log "server binary: OK"

MCPORTER_BIN="$(resolve_mcporter || true)"
[ -n "$MCPORTER_BIN" ] || fail "mcporter not found. Run install.sh first or export MCPORTER_BIN"
log "mcporter: OK ($MCPORTER_BIN)"
log "shared mcporter prefix: $GLOBAL_NPM_PREFIX"
log "local mcporter config: $CONFIG_FILE"

log "checking schema visibility"
(
  cd "$BASE_DIR"
  "$MCPORTER_BIN" list weibo --schema >/tmp/weibo-skill-schema.txt
) || fail "schema check failed"
log "schema check: OK"

if [ "$RUN_SMOKE" = "1" ]; then
  smoke_test
fi

log "check complete"
