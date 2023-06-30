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
    sshguard = { enable = true; };
  };
  programs.ssh.startAgent = true;
  networking.firewall = {
    allowedTCPPorts = [ 22 ];
    allowPing = true;
  };
}
