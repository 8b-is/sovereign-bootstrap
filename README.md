# sovereign-bootstrap 🏛️

**One-shot sovereign workspace bootstrap for 8b.is** — clones, caches, builds, wires the entire constellation.

```bash
# One-liner (macOS Apple Silicon)
curl -fsSL https://raw.githubusercontent.com/8b-is/sovereign-bootstrap/main/install.sh | bash

# Or via Homebrew
brew tap 8b-is/sovereign
brew install sovereign-bootstrap
```

## What Gets Installed

| Component | Purpose | Binary |
|-----------|---------|--------|
| **g8t** (MAIN) | AI-first git for AyeOS (gitoxide) | `g8t` |
| **sccache** | Global Rust compilation cache (50GB) | `sccache` |
| **wupz** | Incremental linker + UPX compressor (Zig SIMD) | `wupz` |
| **upz** | Ultra-evolved linker + beehive + LitanyWireFrame | `upz` |
| **up** | Pure-Zig machine helper (pldev companion) | `up` |
| **pldev** | Go machine helper | `pldev` |
| **omnispherepop** | Weight-programming CLI + MCP | `ospop` |
| **forge-video-infer** | MLX-QUANT b1.58 + CubeCL Metal kernels | `bench-ternary-metal`, `forge-mlx-ring` |
| **unsloth-mcp** | Local training orchestration MCP | `unsloth-mcp` |
| **smart-tree** | Context extractor | `st` |
| **MLX-QUANT** | b1.58 ternary quantization | — |
| **transformers-ultra** | FlashAttn-3 kernels | — |
| **hw-ultra** | Polar dispatch queue | — |

## Foken Minting

Every successful bootstrap **mints Fokens** on the g8t.is leaderboard — your sovereign compute receipt.

## Post-Install

```bash
source ~/.config/8b-is/env.sh
ospop learn --list          # Academy curriculum
up ps                       # System overview
pldev doctor mem            # Memory doctor
g8t status                  # AI-first git status
forge-mlx-ring --help       # Distributed Metal inference
```

---

**Sovereign Root:** `https://8b.is` | **Forge:** `https://github.com/8b-is` | **Codeberg:** `https://codeberg.org/8b-is`
