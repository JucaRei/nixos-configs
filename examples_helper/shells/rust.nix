# This is just for a quick development setup. Otherwise, I recommend
# to use the `rust` template from `nixpkgs` or whatever you prefer.
{
  mkShell,
  openssl,
  pkg-config,
  cargo,
  rustc,
  rustfmt,
  rust-analyzer,
  rustPlatform,
}:
mkShell {
  buildInputs = [
    openssl # In case some package needs it.
    pkg-config # In case some other package needs it.

    # Rust platform.
    cargo
    rustc
    rustfmt
    rust-analyzer
  ];

  RUST_SRC_PATH = rustPlatform.rustLibSrc;

  inputsFrom = [cargo rustc];
}
