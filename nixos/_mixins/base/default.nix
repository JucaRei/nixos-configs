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
    firewall = {
      enable = true;
    };
  };

  programs = {
    dconf.enable = true;
    fish = {
      enable = true;
      shellAbbrs = {
        mkhostid = "head -c4 /dev/urandom | od -A none -t x4";
        # https://github.com/NixOS/nixpkgs/issues/191128#issuecomment-1246030417
        rebuild-home = "home-manager switch -b backup --flake $HOME/Zero/nix-config";
        rebuild-host = "sudo nixos-rebuild switch --flake $HOME/Zero/nix-config";
        rebuild-lock = "pushd $HOME/Zero/nix-config && nix flake lock --recreate-lock-file && popd";
        rebuild-iso = "pushd $HOME/Zero/nix-config && nix build .#nixosConfigurations.iso.config.system.build.isoImage && popd";
        nix-hash-sha256 = "nix-hash --flat --base32 --type sha256";
        nix-gc = "sudo nix-collect-garbage --delete-older-than 4d";
        #rebuild-home = "home-manager switch -b backup --flake $HOME/.setup";
        #rebuild-host = "sudo nixos-rebuild switch --flake $HOME/.setup";
        #rebuild-lock = "pushd $HOME/.setup && nix flake lock --recreate-lock-file && popd";
        #rebuild-iso = "pushd $HOME/.setup && nix build .#nixosConfigurations.iso.config.system.build.isoImage && popd";
      };
    };
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
