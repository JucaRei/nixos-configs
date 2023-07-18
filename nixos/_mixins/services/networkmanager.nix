{pkgs, ...}: {
  networking = {
    firewall = {
      allowedTCPPorts = [22];
      allowPing = true;
    };
    networkmanager = {
      enable = true;
      wifi = {
        backend = "iwd";
        #macAddress = "random";
        #scanRandMacAddress = true;
      };
      ethernet = {
        #macAddress = "random";
      };
      plugins = with pkgs; [
        networkmanager-openvpn
        networkmanager-openconnect
      ];
    };
  };
  # Workaround https://github.com/NixOS/nixpkgs/issues/180175
  #systemd.services.NetworkManager-wait-online.enable = false;
}
