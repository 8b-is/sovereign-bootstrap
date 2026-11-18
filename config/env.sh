# 8b.is Sovereign Environment
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
