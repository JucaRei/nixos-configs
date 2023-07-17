{ pkgs
, lib
, ...
}:
with lib; {
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };

    # Set VM disk size (in MB)
    virtualisation.diskSize = 1024 * 2048;

    boot.growPartition = true;
    boot.kernelParams = [ "console=ttyS0" ];
    boot.loader.grub.device = "/dev/vda";
    boot.loader.timeout = 0;

    i18n.defaultLocale = "de_DE.UTF-8";
    time.timeZone = "Europe/Paris";

    services = {
      timesyncd.enable = lib.mkDefault true;
      openssh = {
        enable = true;
        permitRootLogin = "yes";
      };
    };

    environment.systemPackages = with pkgs; [
      dosfstools
      vim
      netcat
      curl
      openjdk8
    ];

    users.extraUsers.root.password = "";
    users.mutableUsers = false;

    users.users.root = {
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa ... "
      ];
    };
  };
}
