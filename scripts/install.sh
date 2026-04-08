#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENV_DIR="$BASE_DIR/.venv"
BIN_DIR="$VENV_DIR/bin"
CONFIG_DIR="$BASE_DIR/config"
CONFIG_FILE="$CONFIG_DIR/mcporter.json"
SERVER_BIN="$BIN_DIR/mcp-server-weibo"
REPO_URL="git+https://github.com/Panniantong/mcp-server-weibo.git"
GLOBAL_NPM_PREFIX="${GLOBAL_NPM_PREFIX:-/root/.openclaw/workspace/.npm-global}"
GLOBAL_MCPORTER_BIN="$GLOBAL_NPM_PREFIX/bin/mcporter"

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

install_global_mcporter() {
  command -v npm >/dev/null 2>&1 || fail "npm not found, cannot auto-install shared mcporter"
  mkdir -p "$GLOBAL_NPM_PREFIX"
  log "mcporter not found, installing shared mcporter into: $GLOBAL_NPM_PREFIX"
  npm install -g mcporter --prefix "$GLOBAL_NPM_PREFIX"
  [ -x "$GLOBAL_MCPORTER_BIN" ] || fail "shared mcporter install failed: $GLOBAL_MCPORTER_BIN not found"
  printf '%s\n' "$GLOBAL_MCPORTER_BIN"
}

write_local_config() {
  mkdir -p "$CONFIG_DIR"
  cat >"$CONFIG_FILE" <<EOF
{
  "mcpServers": {
    "weibo": {
      "command": "$SERVER_BIN"
    }
  }
}
EOF
}

smoke_test() {
  log "running smoke test: weibo.get_trendings limit:1"
  (
    cd "$BASE_DIR"
    "$MCPORTER_BIN" call weibo.get_trendings limit:1 >/tmp/weibo-skill-smoke.json
  ) || fail "smoke test failed"
  log "smoke test: OK"
}

log "base dir: $BASE_DIR"
command -v python3 >/dev/null 2>&1 || fail "python3 not found"

log "resolving mcporter"
MCPORTER_BIN="$(resolve_mcporter || true)"
if [ -z "$MCPORTER_BIN" ]; then
  MCPORTER_BIN="$(install_global_mcporter)"
fi
[ -x "$MCPORTER_BIN" ] || fail "mcporter unavailable even after shared install attempt"
log "mcporter bin: $MCPORTER_BIN"
log "shared mcporter prefix: $GLOBAL_NPM_PREFIX"

if [ ! -d "$VENV_DIR" ]; then
  log "creating local venv: $VENV_DIR"
  python3 -m venv "$VENV_DIR"
else
  log "local venv already exists: $VENV_DIR"
fi

log "upgrading pip"
"$BIN_DIR/pip" install --upgrade pip >/dev/null

log "installing mcp-server-weibo"
"$BIN_DIR/pip" install "$REPO_URL"
[ -x "$SERVER_BIN" ] || fail "server binary missing after install: $SERVER_BIN"

log "writing local mcporter config"
write_local_config

log "registering weibo server with mcporter"
(
  cd "$BASE_DIR"
  "$MCPORTER_BIN" config add weibo --command "$SERVER_BIN"
) || fail "mcporter registration failed"

log "installed server: $SERVER_BIN"
log "local mcporter config: $CONFIG_FILE"

smoke_test

log "install complete"
