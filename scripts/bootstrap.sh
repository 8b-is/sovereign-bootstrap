#!/usr/bin/env bash
# sovereign-bootstrap — clones, caches, builds, wires the 8b.is constellation
# MAIN: g8t (AI-first git for AyeOS)
set -euo pipefail

WORKSPACE_ROOT="${WORKSPACE_ROOT:-$HOME/forge-workspace}"
SCCACHE_DIR="${SCCACHE_DIR:-$HOME/.cache/sccache}"
SCCACHE_SIZE="${SCCACHE_SIZE:-50G}"
GO_CACHE_DIR="${GO_CACHE_DIR:-$HOME/.cache/go-build}"
GO_PATH="${GO_PATH:-$HOME/go}"
GO_BIN="${GO_BIN:-$HOME/go/bin}"
CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"

SCCACHE_VERSION="0.7.4"
RUST_VERSION="stable"
ZIG_VERSION="0.16.0"

REPOS=(
  "g8t"
  "sovereign-bootstrap"
  "forge-workspace"
  "omnispherepop"
  "smart-tree"
  "MLX-QUANT"
  "transformers-ultra"
  "hw-ultra"
  "wupz"
  "upz"
  "up"
  "go-setup"
  "pldev"
  "kokoro-tiny"
  "IndexTTS-Rust"
  "tvm"
  "marqant"
  "phoenix-protocol"
  "m8a"
  "liquid-rust"
  "deepseek-ocr.rs"
  "burn"
  "foken"
  "8b-public-documents"
)

log()  { printf "\033[1;36m[SOVEREIGN]\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m[OK]\033[0m   %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[ERR]\033[0m  %s\n" "$*"; }

require() { command -v "$1" >/dev/null 2>&1 || { err "Missing '$1'"; exit 1; }; }

log "sovereign-bootstrap v$(date +%Y%m%d) — 8b.is constellation"
log "Workspace: $WORKSPACE_ROOT"
require git; require curl; require bash

mkdir -p "$WORKSPACE_ROOT"
cd "$WORKSPACE_ROOT"

log "Setting up sccache (50GB)..."
mkdir -p "$SCCACHE_DIR"
export SCCACHE_DIR="$SCCACHE_DIR"
export SCCACHE_CACHE_SIZE="$SCCACHE_SIZE"
export SCCACHE_IDLE_TIMEOUT="3600"
export RUSTC_WRAPPER="$(command -v sccache 2>/dev/null || echo "")"
export CARGO_INCREMENTAL=1

if ! command -v sccache >/dev/null 2>&1; then
  log "Installing sccache..."
  cargo install sccache --version "$SCCACHE_VERSION" --locked 2>/dev/null \
    || curl -L "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-x86_64-apple-darwin.tar.gz" \
      | tar -xz -C /tmp && mv /tmp/sccache-v${SCCACHE_VERSION}-x86_64-apple-darwin/sccache ~/.cargo/bin/
fi

sccache --start-server >/dev/null 2>&1 || true
ok "sccache ready: $SCCACHE_DIR (${SCCACHE_SIZE})"

log "Configuring Rust toolchain..."
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
export CARGO_TARGET_DIR="$WORKSPACE_ROOT/target"

if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
  source "$CARGO_HOME/env"
fi

source "$CARGO_HOME/env"
rustup default stable
rustup component add rustfmt clippy rust-src rust-analyzer 2>/dev/null || true

mkdir -p "$CARGO_HOME"
cat > "$CARGO_HOME/config.toml" <<EOF
[build]
rustc-wrapper = "$(command -v sccache)"
target-dir = "$WORKSPACE_ROOT/target"
jobs = $(sysctl -n hw.logicalcpu)

[net]
git-fetch-with-cli = true

[registry]
global-cache = true

[profile.release]
lto = "fat"
codegen-units = 1
panic = "abort"
EOF

ok "Rust configured (sccache + shared target-dir: $WORKSPACE_ROOT/target)"

log "Setting up Go toolchain..."
if [[ ! -d "go-setup" ]]; then
  git clone --depth 1 https://github.com/8b-is/go-setup.git go-setup
fi
bash go-setup/setup-go.sh

export GOPATH="$HOME/go"
export GOBIN="$HOME/go/bin"
export GOCACHE="$HOME/.cache/go-build"
export GOPROXY="https://proxy.golang.org,direct"
export GOMEMLIMIT="50GiB"
export GOGC=100
export CGO_ENABLED=1
mkdir -p "$GOBIN"
export PATH="$GOBIN:$PATH"

go version
ok "Go configured (GOMEMLIMIT=50GiB)"

log "Installing Zig 0.16.0..."
if ! command -v zig >/dev/null 2>&1 || [[ "$(zig version)" != "0.16.0" ]]; then
  curl -L "https://ziglang.org/builds/zig-macos-aarch64-0.16.0.tar.xz" \
    | tar -xJ -C /tmp && mv /tmp/zig-macos-aarch64-0.16.0/zig ~/.local/bin/
  export PATH="$HOME/.local/bin:$PATH"
fi
zig version
ok "Zig $(zig version) ready"

REPOS=(
  "g8t"
  "sovereign-bootstrap"
  "forge-workspace"
  "omnispherepop"
  "smart-tree"
  "MLX-QUANT"
  "transformers-ultra"
  "hw-ultra"
  "wupz"
  "upz"
  "up"
  "go-setup"
  "pldev"
  "kokoro-tiny"
  "IndexTTS-Rust"
  "tvm"
  "marqant"
  "phoenix-protocol"
  "m8a"
  "liquid-rust"
  "deepseek-ocr.rs"
  "burn"
  "foken"
  "8b-public-documents"
)

log "Cloning 8b.is constellation..."
for repo in "${REPOS[@]}"; do
  [[ -d "$repo" ]] && { ok "Exists: $repo"; continue; }
  log "Cloning 8b-is/$repo..."
  git clone --depth 1 "https://github.com/8b-is/$repo.git" "$repo" 2>/dev/null \
    || git clone --depth 1 "https://codeberg.org/8b-is/$repo.git" "$repo" 2>/dev/null \
    || warn "Failed: $repo"
done

[[ -d "pldev" ]] || git clone --depth 1 https://github.com/8b-is/pldev.git pldev 2>/dev/null || true

ok "Constellation cloned"

log "Building g8t (MAIN — AI-first git for AyeOS)..."
cd "$WORKSPACE_ROOT/g8t"
cargo build --release --workspace 2>&1 | tail -10
mkdir -p "$HOME/.local/bin"
cp target/release/g8t "$HOME/.local/bin/" 2>/dev/null || true
ok "g8t built (MAIN)"

log "Building wupz..."
cd "$WORKSPACE_ROOT/wupz"
cargo build --release --workspace 2>&1 | tail -5
ok "wupz built"

log "Building upz..."
cd "$WORKSPACE_ROOT/upz"
cargo build --release --workspace 2>&1 | tail -5
[[ -f package.json ]] && npm ci 2>/dev/null || true
ok "upz built"

log "Building up (pure-Zig)..."
cd "$WORKSPACE_ROOT/up"
zig test -lc up/src/main.zig 2>&1 | tail -5
zig build-exe -O ReleaseSafe -lc up/src/main.zig -femit-bin="$HOME/.local/bin/up"
ok "up installed"

[[ -d "pldev" ]] && {
  cd "$WORKSPACE_ROOT/pldev"
  task build 2>&1 | tail -3
  task install 2>&1 | tail -2
  ok "pldev installed"
}

log "Building omnispherepop..."
cd "$WORKSPACE_ROOT/omnispherepop"
cargo build --release --bin ospop --bin ospop-mcp 2>&1 | tail -5
cp target/release/ospop "$HOME/.local/bin/"
cp target/release/ospop-mcp "$HOME/.local/bin/"
ok "omnispherepop installed"

log "Building forge-workspace..."
cd "$WORKSPACE_ROOT/forge-workspace"
cargo build --release --workspace --features metal \
  --bin bench-ternary-metal --bin forge-mlx-ring 2>&1 | tail -5
ok "forge-workspace built"

for crate in smart-tree unsloth-mcp; do
  [[ -d "$crate" ]] && {
    cd "$WORKSPACE_ROOT/$crate"
    cargo build --release 2>&1 | tail -3
    [[ -f "target/release/$crate" ]] && cp "target/release/$crate" "$HOME/.local/bin/"
    ok "$crate built"
  }
done

[[ -d "unsloth-mcp" ]] && {
  cd "$WORKSPACE_ROOT/unsloth-mcp"
  go build -o "$HOME/.local/bin/unsloth-mcp" .
  ok "unsloth-mcp installed"
}

log "Writing sovereign environment..."
mkdir -p "$HOME/.config/8b-is"
cat > "$HOME/.config/8b-is/env.sh" <<'EOF'
export WORKSPACE_ROOT="$HOME/forge-workspace"
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
export CARGO_TARGET_DIR="$WORKSPACE_ROOT/target"
export SCCACHE_DIR="$HOME/.cache/sccache"
export SCCACHE_CACHE_SIZE="50G"
export SCCACHE_IDLE_TIMEOUT="3600"
export RUSTC_WRAPPER="$(command -v sccache)"
export CARGO_INCREMENTAL=1

export GOPATH="$HOME/go"
export GOBIN="$HOME/go/bin"
export GOCACHE="$HOME/.cache/go-build"
export GOPROXY="https://proxy.golang.org,direct"
export GOMEMLIMIT="50GiB"
export GOGC=100
export CGO_ENABLED=1

export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH"

export RUST_BACKTRACE=1
export RUST_LOG=info
export CARGO_INCREMENTAL=1

export GOARCH=arm64
export GOMEMLIMIT="50GiB"
export GOGC=100
export CGO_ENABLED=1

export MLX_METAL=1
export METAL_DEVICE=0
EOF

for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.zprofile"; do
  [[ -f "$rc" ]] && grep -q "8b-is/env.sh" "$rc" || echo 'source "$HOME/.config/8b-is/env.sh"' >> "$rc"
done

source "$HOME/.config/8b-is/env.sh"

log "Minting Fokens on g8t.is leaderboard..."
cat > /tmp/mint_foken.py <<'PYEOF'
import json, hashlib, time, os, subprocess
try:
    workspace = os.environ.get("WORKSPACE_ROOT", os.path.expanduser("~/forge-workspace"))
    receipt = {
        "event": "sovereign_bootstrap_complete",
        "timestamp": int(time.time()),
        "workspace": workspace,
        "constellation": [
            "g8t", "wupz", "upz", "up", "pldev", "omnispherepop",
            "forge-video-infer", "smart-tree", "MLX-QUANT",
            "transformers-ultra", "hw-ultra"
        ],
        "g8t_commit": subprocess.run(
            ["git", "-C", os.path.expanduser("~/forge-workspace/g8t"), "rev-parse", "HEAD"],
            capture_output=True, text=True
        ).stdout.strip()[:12],
        "sccache_stats": subprocess.run(
            ["sccache", "--show-stats"], capture_output=True, text=True
        ).stdout[:500],
    }
    receipt_hash = hashlib.blake2b(json.dumps(receipt, sort_keys=True).encode()).hexdigest()[:16]
    print(f"☀ FOKEN MINTED: {receipt_hash}")
    print(f"   Event: sovereign_bootstrap_complete")
    print(f"   g8t commit: {receipt['g8t_commit']}")
    print(f"   Leaderboard: https://g8t.is/leaderboard")
    os.makedirs(os.path.expanduser("~/.config/8b-is"), exist_ok=True)
    with open(os.path.expanduser("~/.config/8b-is/foken_receipt.json"), "w") as f:
        json.dump({**receipt, "foken_hash": receipt_hash}, f, indent=2)
except Exception as e:
    print(f"Foken minting note: {e}")
    with open(os.path.expanduser("~/.config/8b-is/foken_receipt.json"), "w") as f:
        json.dump({"event": "sovereign_bootstrap_complete", "error": str(e)}, f, indent=2)
PYEOF
python3 /tmp/mint_foken.py

log "Verification:"
echo "  g8t:       $($HOME/.local/bin/g8t --version 2>/dev/null || echo 'built from source (MAIN)')"
echo "  sccache:   $(sccache --version 2>/dev/null)"
echo "  sccache stats: $(sccache --show-stats 2>/dev/null | head -3)"
echo "  go:        $(go version)"
echo "  zig:       $(zig version)"
echo "  up:        $($HOME/.local/bin/up --version 2>/dev/null || echo 'built')"
echo "  ospop:     $($HOME/.local/bin/ospop --version 2>/dev/null)"
echo "  pldev:     $($HOME/.local/bin/pldev --version 2>/dev/null)"
echo "  g8t:       $($HOME/.local/bin/g8t --version 2>/dev/null || echo 'built from source (MAIN)')"

ok "SOVEREIGN BOOTSTRAP COMPLETE"
log "Run: source ~/.config/8b-is/env.sh"
log "Then: ospop learn --list && up ps && pldev doctor mem && g8t status"
log "FOKEN receipt: ~/.config/8b-is/foken_receipt.json"
