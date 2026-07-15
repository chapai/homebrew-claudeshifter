class Clauch < Formula
  desc "Shift Claude models with a USB racing shifter"
  homepage "https://github.com/chapai/claudeshifter"
  url "https://github.com/chapai/claudeshifter/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "b061cbda1092aa86483f5d56b6cf85ee7a46793ef0e4b3c4273b9c18eee1be77"
  license "WTFPL"

  depends_on "elixir" => :build
  depends_on "rust" => :build
  depends_on "erlang"

  def install
    ENV["MIX_ENV"] = "prod"
    system "mix", "deps.get"
    # elixir_make compiler runs the Makefile, which cargo-builds the
    # native/hid_reader NIF crate into priv/hid_reader.so (hidapi is vendored
    # by the crate — no system hidapi needed)
    system "mix", "escript.build"

    libexec.install "clauch"
    libexec.install "priv"

    # Default config, preserved across upgrades (Homebrew keeps user-modified etc files).
    # The app copies this to ~/.config/clauch/config.yaml on first startup.
    pkgetc.install "config.yaml"

    # Wrapper: fall back to the etc config only when the app would find none itself
    # (it searches $CLAUCH_CONFIG, then ./config.yaml, then ~/.config/clauch/config.yaml).
    (bin/"clauch").write <<~SH
      #!/bin/bash
      if [ -z "$CLAUCH_CONFIG" ] \\
         && [ ! -f "$PWD/config.yaml" ] \\
         && [ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/clauch/config.yaml" ]; then
        export CLAUCH_CONFIG="#{pkgetc}/config.yaml"
      fi
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
    assert_path_exists libexec/"priv/hid_reader.so"
  end
end
