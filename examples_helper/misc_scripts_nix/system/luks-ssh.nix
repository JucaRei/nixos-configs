# NixOS: Unlock LUKS via ssh
{ config, pkgs, lib, ... }:
{
  # I added these lines to my configuration.nix to make ssh LUKS unlocking work on my Fujitsu Futro

  # The kernel driver (find out with lspci -v) for the network unit
    boot.initrd.availableKernelModules = [ "r8169" ];
    
    boot.initrd.network.ssh = {
      enable = true;
      port = 2222; # I think the port should be different from the default one if a ssh server is running on the system at 22
      authorizedKeys = [ "ssh-rsa AAAA...= user@host" ];
      
      # Create the keys like here: https://nixos.wiki/wiki/Remote_LUKS_Unlocking
      hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
    
    # This presents the key prompt after ssh'ing into the system (otherwise you have to execute 'cryptsetup-askpass' manually)
    boot.initrd.network.postCommands = "echo 'cryptsetup-askpass' >> /root/.profile";
    
    # Probably required
    networking.useDHCP = false;
    networking.interfaces.<interface>.useDHCP = true;
}