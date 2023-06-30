{ hostid, hostname, username, lib, pkgs, ... }: {
  imports = [
    ./locale.nix
    ./nano.nix
    ../services/fwupd.nix
    ../services/android.nix
    ../services/ntp.nix
    ../services/openssh.nix
    ../services/firewall.nix
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
    micro
    exfat
    pciutils
    usbutils
    rsync
    unzip
    wget
    xdg-utils
    lm_sensors
  ];

  # Use passed in hostid and hostname to configure basic networking
  networking = {
    hostName = hostname;
    hostId = hostid;
    useDHCP = lib.mkDefault true;
    #extraHosts = ''
    #  192.168.192.59  trooper-zt
    #  192.168.192.220 ripper-zt
    #'';
  };

  programs = {
    command-not-found.enable = false;
    fish = {
      enable = true;
      shellAbbrs = {
        mkhostid = "head -c4 /dev/urandom | od -A none -t x4";
        # https://github.com/NixOS/nixpkgs/issues/191128#issuecomment-1246030417
        nix-gc           = "sudo nix-collect-garbage --delete-older-than 14d";
        rebuild-home     = "home-manager switch -b backup --flake $HOME/Zero/nix-config";
        rebuild-host     = "sudo nixos-rebuild switch --flake $HOME/Zero/nix-config";
        rebuild-lock     = "pushd $HOME/Zero/nix-config && nix flake lock --recreate-lock-file && popd";
        rebuild-iso      = "pushd $HOME/Zero/nix-config && nix build .#nixosConfigurations.iso.config.system.build.isoImage && popd";
        rebuild-iso-mini = "pushd $HOME/Zero/nix-config && nix build .#nixosConfigurations.iso-mini.config.system.build.isoImage && popd";
        nix-hash-sha256 = "nix-hash --flat --base32 --type sha256";
        #rebuild-home = "home-manager switch -b backup --flake $HOME/.setup";
        #rebuild-host = "sudo nixos-rebuild switch --flake $HOME/.setup";
        #rebuild-lock = "pushd $HOME/.setup && nix flake lock --recreate-lock-file && popd";
        #rebuild-iso = "pushd $HOME/.setup && nix build .#nixosConfigurations.iso.config.system.build.isoImage && popd";
      };
    };
  };

  # Create dirs for home-manager
  systemd.tmpfiles.rules = [ 
    "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
  ];

  ## Some optimizations services as default
  security.rtkit.enable = true;
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
