{ pkgs, ... }: {
  networking = {
    firewall = {
      allowedTCPPorts = [ 22 ];
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
    extraHosts = ''
      192.168.1.50  nitro
      192.168.1.35  nitro
      192.168.1.230 air
      192.168.1.200 DietPi
      192.168.1.76  oldmac
    '';
  };
  # Workaround https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
