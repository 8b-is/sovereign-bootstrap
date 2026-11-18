#!/usr/bin/env bash
# sovereign-bootstrap one-liner installer
set -euo pipefail

REPO="8b-is/sovereign-bootstrap"
BRANCH="main"
INSTALL_DIR="${HOME}/.local/share/sovereign-bootstrap"
BIN_DIR="${HOME}/.local/bin"

log() { printf "\033[1;36m[SOVEREIGN]\033[0m %s\n" "$*"; }
ok()  { printf "\033[1;32m[OK]\033[0m   %s\n" "$*"; }

log "Downloading sovereign-bootstrap..."
mkdir -p "$INSTALL_DIR" "$BIN_DIR"
cd "$INSTALL_DIR"

if [[ -d .git ]]; then
  git fetch origin "$BRANCH" && git reset --hard "origin/$BRANCH"
else
  git clone --depth 1 --branch "$BRANCH" "https://github.com/$REPO.git" .
fi

chmod +x scripts/bootstrap.sh
"$INSTALL_DIR/scripts/bootstrap.sh"

ln -sf "$INSTALL_DIR/scripts/bootstrap.sh" "$BIN_DIR/sovereign-bootstrap" 2>/dev/null || true

ok "sovereign-bootstrap installed. Run: source ~/.config/8b-is/env.sh"
ok "Then: sovereign-bootstrap --help"
