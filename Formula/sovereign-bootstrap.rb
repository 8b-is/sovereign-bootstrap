class SovereignBootstrap < Formula
  desc "One-shot sovereign workspace bootstrap for 8b.is constellation"
  homepage "https://github.com/8b-is/sovereign-bootstrap"
  url "https://github.com/8b-is/sovereign-bootstrap/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_ACTUAL_SHA256"
  license "MIT OR Apache-2.0"
  head "https://github.com/8b-is/sovereign-bootstrap.git", branch: "main"

  depends_on "git"
  depends_on "curl"
  depends_on "rust" => :build
  depends_on "go" => :build
  depends_on "zig" => :build
  depends_on "sccache" => :build

  def install
    bin.install "scripts/bootstrap.sh" => "sovereign-bootstrap"
    bin.install "install.sh" => "sovereign-bootstrap-install"
    (etc/"8b-is").install "config/env.sh" => "env.sh"
  end

  def caveats
    <<~EOS
      To complete the sovereign bootstrap:
        sovereign-bootstrap

      Then source the environment:
        source #{etc}/8b-is/env.sh

      The bootstrap will:
        1. Install sccache (50GB cache)
        2. Configure Rust toolchain with shared target-dir
        3. Setup Go toolchain (GOMEMLIMIT=50GiB)
        4. Install Zig 0.16.0
        5. Clone 8b.is constellation (g8t, wupz, upz, up, omnispherepop, etc.)
        6. Build g8t (MAIN - AI-first git for AyeOS)
        7. Build wupz, upz, up, pldev
        8. Build omnispherepop, forge-workspace, smart-tree
        9. Mint Fokens on g8t.is leaderboard

      Post-install:
        source #{etc}/8b-is/env.sh
        ospop learn --list
        up ps
        g8t status
    EOS
  end

  test do
    system "#{bin}/sovereign-bootstrap", "--help"
  end
end
