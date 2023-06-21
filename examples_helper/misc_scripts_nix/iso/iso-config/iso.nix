# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage --arg configuration "{ imports = [ ./iso.nix ]; }"
# or nixos-generate -f iso -c iso.nix
# This module defines a small NixOS installation CD.  It does not
# contain any graphical stuff.
{
  config,
  pkgs,
  ...
}: {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    ./iso-config.nix
    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];
}
