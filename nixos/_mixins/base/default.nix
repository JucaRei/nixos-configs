{
  hostid,
  hostname,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./locale.nix
    ./nano.nix
    ../services/fwupd.nix
    ../services/android.nix
    ../services/ntp.nix
    ../services/openssh.nix
    ../services/optimizations.nix
    #../services/tailscale.nix
    #../services/zerotier.nix
    #../hardware/gfx-intel.nix
  ];

  # don't install documentation i don't use
  documentation.enable = true; # documentation of packages
  documentation.nixos.enable = false; # nixos documentation
  documentation.man.enable = true; # manual pages and the man command
  documentation.info.enable = false; # info pages and the info command
  documentation.doc.enable = false; # documentation distributed in packages' /share/doc

  environment.systemPackages = with pkgs; [
    binutils
    curl
    wget
    desktop-file-utils
    file
    git
    home-manager
    killall
    man-pages
    #mergerfs
    #mergerfs-tools
    nano
    exfat
    pciutils
    usbutils
    rsync
    unzip
    #v4l-utils
    wget
    xdg-utils
    lm_sensors
  ];

  # Use passed in hostid and hostname to configure basic networking
  networking = {
    hostName = hostname;
    hostId = hostid;
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
    };
  };

  programs = {
    dconf.enable = true;
    fish.enable = true;
  };

  security.rtkit.enable = true;

  ## Some optimizations services as default
  services = {
    udisks2.enable = true;
    ananicy = {
      package = pkgs.ananicy-cpp;
      enable = true;
    };
    earlyoom.enable = true;
    irqbalance.enable = true;
    fstrim.enable = true;
  };
}
