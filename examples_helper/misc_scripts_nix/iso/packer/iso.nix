{
  config,
  pkgs,
  ...
}: {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

  # TODO: this didn't actually seem to work
  systemd.services.cloud-init.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
}
