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

  boot = {
    kernelParams = [
      # The 'splash' arg is included by the plymouth option
      "quiet"
      #"loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_priority=3"
      "udev.log_priority=3"
      "vt.global_cursor_default=0"
      "mitigations=off"
      #"zswap.enabled=1"
      #"zswap.compressor=lz4hc"
      #"zswap.max_pool_percent=20"
      #"zswap.zpool=z3fold"
      "net.ifnames=0"
      "mem_sleep_default=deep"
    ];
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };

  console = {
    earlySetup = true;
    packages = [ pkgs.terminus_font pkgs.powerline-fonts ];
  };

  # don't install documentation i don't use
  documentation.enable = true; # documentation of packages
  documentation.nixos.enable = false; # nixos documentation
  documentation.man.enable = true; # manual pages and the man command
  documentation.info.enable = false; # info pages and the info command
  documentation.doc.enable =
    false; # documentation distributed in packages' /share/doc

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
    duf
    neofetch
  ];

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override {
        fonts = [ "FiraCode" "SourceCodePro" "UbuntuMono" ];
      })
      fira
      fira-go
      joypixels
      liberation_ttf
      noto-fonts-emoji
      source-serif
      ubuntu_font_family
      work-sans
    ];

    # use fonts specified by user rather than default ones
    enableDefaultFonts = false;

    fontconfig = {
      antialias = true;
      cache32Bit = true;
      defaultFonts = {
        serif = [ "Source Serif" ];
        sansSerif = [ "Work Sans" "Fira Sans" "FiraGO" ];
        monospace = [ "FiraCode Nerd Font Mono" ];
        emoji = [ "Joypixels" "Noto Color Emoji" ];
      };
      enable = true;
      hinting = {
        autohint = false;
        enable = true;
        style = "hintslight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "light";
      };
    };
  };

  # Accept the joypixels license
  nixpkgs.config.joypixels.acceptLicense = true;

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
        nix-gc = "sudo nix-collect-garbage --delete-older-than 14d";
        rebuild-home =
          "home-manager switch -b backup --flake $HOME/Zero/nix-config";
        rebuild-host =
          "sudo nixos-rebuild switch --flake $HOME/Zero/nix-config";
        rebuild-lock =
          "pushd $HOME/Zero/nix-config && nix flake lock --recreate-lock-file && popd";
        rebuild-iso =
          "pushd $HOME/Zero/nix-config && nix build .#nixosConfigurations.iso.config.system.build.isoImage && popd";
        rebuild-iso-mini =
          "pushd $HOME/Zero/nix-config && nix build .#nixosConfigurations.iso-mini.config.system.build.isoImage && popd";
        nix-hash-sha256 = "nix-hash --flat --base32 --type sha256";
        #rebuild-home = "home-manager switch -b backup --flake $HOME/.setup";
        #rebuild-host = "sudo nixos-rebuild switch --flake $HOME/.setup";
        #rebuild-lock = "pushd $HOME/.setup && nix flake lock --recreate-lock-file && popd";
        #rebuild-iso = "pushd $HOME/.setup && nix build .#nixosConfigurations.iso.config.system.build.isoImage && popd";
      };
    };
  };

  systemd = {
    # Create dirs for home-manager
    tmpfiles.rules = [
      "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
      "d /mnt/snapshot/${username} 0755 ${username} users"
    ];

    # Change build dir to /var/tmp
    services.nix-daemon = { environment.TMPDIR = "/var/tmp"; };

    # Reduce default service stop timeouts for faster shutdown
    extraConfig = ''
      DefaultTimeoutStopSec=15s
      DefaultTimeoutAbortSec=5s
    '';

    # systemd's out-of-memory daemon
    oomd = {
      enable = lib.mkDefault true;
      enableSystemSlice = true;
      enableUserServices = true;
    };
  };

  ## Some optimizations services as default
  security = {
    rtkit.enable = true;

    # required by podman to run containers in rootless mode when using linuxPackages_hardened
    # unprivilegedUsernsClone = true;
  };

  services = {
    udisks2.enable = true;
    ananicy = {
      package = pkgs.ananicy-cpp;
      enable = true;
    };
    earlyoom.enable = true;
    irqbalance.enable = true;
    fstrim.enable = true;

    dbus.implementation = "broker";

    resolved = {
      extraConfig = ''
        # No need when using Avahi
        MulticastDNS=no
      '';
    };

    kmscon = {
      enable = true;
      hwRender = true;
      extraConfig = ''
        font-name=FiraCode Nerd Font Mono, SauceCodePro Nerd Font Mono
        font-size=14
      '';
    };

    # For battery status reporting
    #upower = { enable = true; };

    # Only suspend on lid closed when laptop is disconnected
    #logind = {
    #  lidSwitch = "suspend-then-hibernate";
    #  lidSwitchDocked = lib.mkDefault "ignore";
    #  lidSwitchExternalPower = lib.mkDefault "lock";
    #};

    # Suspend when power key is pressed
    logind.extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
    '';
  };
}
