{
  config,
  lib,
  pkgs,
  ...
}: {
  networking = {
    networkmanager = {
      enable = true;
      wifi = {
        backend = "iwd";
      };
      plugins = with pkgs; [
        networkmanager-openvpn
        networkmanager-openconnect
      ];
    };
  };
  # Workaround https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
