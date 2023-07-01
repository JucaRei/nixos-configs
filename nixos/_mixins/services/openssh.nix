{ lib, ... }: {
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = lib.mkDefault "no";
        X11Forwarding = true; # enable X11 forwarding
      };
    };
    sshguard = { 
      enable = true;
      whitelist = [
        "192.168.1.230/24"
        "192.168.1.45/24"
        #"62.31.16.154"
        #"80.209.186.67"
      ]; 
    };
  };
  programs.ssh.startAgent = true;
  networking.firewall = {
    allowedTCPPorts = [ 22 ];
    allowPing = true;
  };
}
