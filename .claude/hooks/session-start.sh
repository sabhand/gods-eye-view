#!/bin/bash
# Prepares Claude Code cloud sessions: Node 24 LTS, npm deps, and a Chromium for puppeteer QA gates.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

NODE_DIR="$HOME/.local/node24"

node_ok() {
  "$1" -e 'const [a,b]=process.versions.node.split(".").map(Number);process.exit((a===24&&b>=14)||a===26?0:1)' 2>/dev/null
}

if command -v node >/dev/null && node_ok node; then
  NODE_BIN="$(dirname "$(command -v node)")"
elif [ -x "$NODE_DIR/bin/node" ] && node_ok "$NODE_DIR/bin/node"; then
  NODE_BIN="$NODE_DIR/bin"
else
  version="$(curl -fsSL https://nodejs.org/dist/index.json | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>console.log(JSON.parse(s).find(r=>r.version.startsWith("v24.")).version))' 2>/dev/null \
    || curl -fsSL https://nodejs.org/dist/index.json | grep -o '"version":"v24\.[0-9.]*"' | head -1 | cut -d'"' -f4)"
  rm -rf "$NODE_DIR" && mkdir -p "$NODE_DIR"
  curl -fsSL "https://nodejs.org/dist/${version}/node-${version}-linux-x64.tar.xz" | tar -xJ -C "$NODE_DIR" --strip-components=1
  NODE_BIN="$NODE_DIR/bin"
fi
export PATH="$NODE_BIN:$PATH"

# Use the preinstalled Playwright Chromium for puppeteer instead of downloading one.
chrome="$(find /opt/pw-browsers -path '*chrome-linux*/chrome' -type f 2>/dev/null | head -1 || true)"
export PUPPETEER_SKIP_DOWNLOAD=1

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  {
    echo "export PATH=\"$NODE_BIN:\$PATH\""
    echo "export PUPPETEER_SKIP_DOWNLOAD=1"
    [ -n "$chrome" ] && echo "export PUPPETEER_EXECUTABLE_PATH=\"$chrome\""
  } >> "$CLAUDE_ENV_FILE"
fi

npm install --no-audit --no-fund
