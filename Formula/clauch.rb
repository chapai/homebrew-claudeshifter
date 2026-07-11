class Clauch < Formula
  desc "Shift Claude models with a USB racing shifter"
  homepage "https://github.com/chapai/claudeshifter"
  url "https://github.com/chapai/claudeshifter/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_TARBALL_SHA256"
  license "WTFPL"

  depends_on "elixir" => :build
  depends_on "pkg-config" => :build
  depends_on "erlang"
  depends_on "hidapi"

  def install
    ENV["MIX_ENV"] = "prod"
    system "mix", "deps.get"
    # elixir_make compiler runs the Makefile, building priv/hid_reader (links hidapi)
    system "mix", "escript.build"

    libexec.install "clauch"
    libexec.install "priv"
    (bin/"clauch").write_env_script libexec/"clauch", {}
  end

  test do
    assert_match "hid_reader binary not found", shell_output("#{bin}/clauch 2>&1", 1)
  end
end
