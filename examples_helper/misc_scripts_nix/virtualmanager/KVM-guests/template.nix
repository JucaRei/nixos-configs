# # Declarative configuration of the template KVM guest
{ pkgs, ... }: {
  networking.hostName = "template";
  networking.firewall.allowedTCPPorts = [ 22 ];

  networking.interfaces.eth0 = {
    ipAddress = "176.32.0.254";
    prefixLength = 24;
  };

  environment.systemPackages = with pkgs; [ wget ];

  virtualisation = {
    memorySize = 512;
    qemu.networkingOptions =
      [ "-net nic,macaddr=52:54:00:12:34:01" "-net vde,sock=/run/vde.ctl" ];
  };
}
