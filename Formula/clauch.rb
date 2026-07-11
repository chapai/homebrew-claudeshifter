class Clauch < Formula
  desc "Shift Claude models with a USB racing shifter"
  homepage "https://github.com/chapai/claudeshifter"
  url "https://github.com/chapai/claudeshifter/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "1d40ded62d3e5f09252bcc6407a82ac1cb096226391124f05bba3fe80934e39b"
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

    # Default config, preserved across upgrades (Homebrew keeps user-modified etc files).
    pkgetc.install "config.yaml"

    # Wrapper: default CLAUCH_CONFIG to the etc copy unless the user set their own.
    (bin/"clauch").write <<~SH
      #!/bin/bash
      export CLAUCH_CONFIG="${CLAUCH_CONFIG:-#{pkgetc}/config.yaml}"
      exec "#{libexec}/clauch" "$@"
    SH
  end

  def caveats
    <<~EOS
      A default config was installed to:
        #{pkgetc}/config.yaml
      Edit it with your shifter's vendor/product IDs and tmux target.
      Override the location by setting CLAUCH_CONFIG.
    EOS
  end

  test do
    assert_path_exists etc/"clauch/config.yaml"
    assert_path_exists libexec/"priv/hid_reader"
  end
end
