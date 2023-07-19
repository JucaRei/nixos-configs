{
  pkgs,
  username,
  lib,
  ...
}: {
  imports = [
    ../services/kmscon.nix
    ../services/openssh.nix
    ../services/firewall.nix
    ../services/fwupd.nix
    #../services/ntp.nix
    ../services/pipewire.nix
    ../services/security.nix
    ../users/root
    #../services/tailscale.nix
    #../services/zerotier.nix
    ../users/${username}

    ../hardware/bluetooth.nix
  ];

  boot = {
    initrd = {verbose = false;};
    consoleLogLevel = 0;
    kernelModules = ["vhost_vsock" "kvm-intel"];
    kernelParams = [
      # The 'splash' arg is included by the plymouth option
      "quiet"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "net.ifnames=0"
    ];
    kernel = {
      sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
        "dev.i915.perf_stream_paranoid" = 0;

        ### Improve networking
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "fq";

        # Bypass hotspot restrictions for certain ISPs
        "net.ipv4.ip_default_ttl" = 65;
      };
    };
  };

  console = {
    keyMap =
      if (builtins.isString == "nitro")
      then "br-abnt2"
      else "us";
    earlySetup = true;
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    packages = with pkgs; [tamzen];
  };

  i18n = {
    defaultLocale = "en_US.utf8";
    extraLocaleSettings = {
      #LC_CTYPE = lib.mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_ADDRESS = "pt_BR.utf8";
      LC_IDENTIFICATION = "pt_BR.utf8";
      LC_MEASUREMENT = "pt_BR.utf8";
      LC_MONETARY = "pt_BR.utf8";
      LC_NAME = "pt_BR.utf8";
      LC_NUMERIC = "pt_BR.utf8";
      LC_PAPER = "pt_BR.utf8";
      LC_TELEPHONE = "pt_BR.utf8";
      LC_TIME = "pt_BR.utf8";
      #LC_COLLATE = "pt_BR.utf8";
      #LC_MESSAGES = "pt_BR.utf8";
    };
    supportedLocales = ["en_US.UTF-8/UTF-8" "pt_BR.UTF-8/UTF-8"];
  };

  ######################################
  ### Default Services for all hosts ###
  ######################################

  services = {
    xserver = {
      layout = "us";
      xkbModel = lib.mkDefault "pc105";
    };

    ananicy = {
      enable = lib.mkDefault true;
      package = pkgs.ananicy-cpp;
    };

    earlyoom = {
      enable = lib.mkDefault false;
    };

    irqbalance = {
      enable = true;
    };

    fstrim = {
      enable = true; ### ssd's
    };

    dbus = {
      implementation = lib.mkDefault "broker";
    };

    resolved = {
      enable = true;
      extraConfig = ''
        # No need when using Avahi
        MulticastDNS=no
      '';
    };

    logind = {
      lidSwitch = "suspend";
      #extraConfig = ''
      #  HandlePowerKey=suspend-then-hibernate
      #'';
    };

    # For battery status reporting
    #upower = { enable = true; };

    # Only suspend on lid closed when laptop is disconnected
    #logind = {
    #  lidSwitch = "suspend-then-hibernate";
    #  lidSwitchDocked = lib.mkDefault "ignore";
    #  lidSwitchExternalPower = lib.mkDefault "lock";
    #};
  };
  time.timeZone = lib.mkDefault "America/Sao_Paulo";
  #location = {
  #  latitude = -23.539380;
  #  longitude = -46.652530;
  #};

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override {
        fonts = ["FiraCode" "SourceCodePro" "UbuntuMono"];
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

    # Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
    enableDefaultFonts = false;

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = ["Source Serif"];
        sansSerif = ["Work Sans" "Fira Sans" "FiraGO"];
        monospace = ["FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono"];
        emoji = ["Joypixels" "Noto Color Emoji"];
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
}
