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
  };
}
