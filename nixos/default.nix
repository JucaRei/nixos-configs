{ config
, desktop
, hostname
, hostid
, inputs
, lib
, modulesPath
, outputs
, pkgs
, stateVersion
, username
, ...
}:
let machines = [ "nitro" "air" ];
in {
  # Import host specific boot and hardware configurations.
  # Only include desktop components if one is supplied.
  # - https://nixos.wiki/wiki/Nix_Language:_Tips_%26_Tricks#Coercing_a_relative_path_with_interpolated_variables_to_an_absolute_path_.28for_imports.29
  imports = [
    #(./. + "/${hostname}/disks.nix")
    #(./. + "/${hostname}/hardware.nix")
    #(./. + "/${hostname}/boot.nix")

    #inputs.disko.nixosModules.disko    
    (modulesPath + "/installer/scan/not-detected.nix")
    (./. + "/${hostname}")
    ./_mixins/services/kmscon.nix
    ./_mixins/services/openssh.nix
    ./_mixins/services/firewall.nix
    ./_mixins/services/flatpak.nix
    ./_mixins/services/fwupd.nix
    ./_mixins/services/ntp.nix
    ./_mixins/services/bluetooth.nix
    ./_mixins/services/security.nix
    ./_mixins/users/root
    #../services/tailscale.nix
    #../services/zerotier.nix
    ./_mixins/users/${username}
  ]
  #++ lib.optional (builtins.pathExists (./. + "/${hostname}/disks.nix")) ./${hostname}/disks.nix
  #++ lib.optional (builtins.pathExists (./. + "/${hostname}/disks.nix")) (import ./${hostname}/disks.nix { })
  #++ lib.optional (builtins.pathExists (./. + "/${hostname}/extra.nix")) (import ./${hostname}/extra.nix { })

  ++ lib.optional (builtins.elem hostname machines) ./_mixins/hardware/gfx-intel.nix
  ++ lib.optional (builtins.isString desktop) ./_mixins/desktop;

  boot = {
    initrd = { verbose = false; };
    consoleLogLevel = 0;
    kernelModules = [ "vhost_vsock" ];
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
    keyMap = if (builtins.isString == "nitro") then "br-abnt2" else "us";
    earlySetup = true;
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    packages = with pkgs; [ tamzen ];
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
    supportedLocales = [ "en_US.UTF-8/UTF-8" "pt_BR.UTF-8/UTF-8" ];
  };

  services = {
    xserver = 

    ################
    ### Keyboard ###
    ################
      if (builtins.isString == "nitro" && "vm") then {
        layout = "br,gb,us";
        xkbVariant = "pc105";
        xkbModel = "pc105";
        xkbOptions = "grp:alt_shift_toggle";
      } else {
        layout = "us";
        xkbVariant = "mac";
        xkbModel = "pc105";
        xkbOptions = ''
          "altwin:ctrl_win"
          "altwin:ctrl_alt_win"
          "caps:super" 
          "terminate:ctrl_alt_bksp" 
        '';
        #"caps:ctrl_modifier"
        #"lv3:alt_switch"
        #"lv3:switch,compose:lwin”
        enable = true;
      };
      

    ##################
    ### More Stuff ###
    ##################
    udisks2.enable = true;
    ananicy = {
      package = pkgs.ananicy-cpp;
      enable = true;
    };
    earlyoom.enable = false;
    irqbalance.enable = true;
    fstrim.enable = true;

    dbus.implementation = "broker";

    resolved = {
      extraConfig = ''
        # No need when using Avahi
        MulticastDNS=no
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
    logind = {
      lidSwitch = "suspend";
      extraConfig = ''
        HandlePowerKey=suspend-then-hibernate
      '';
    };

  };
  time.timeZone = lib.mkDefault "America/Sao_Paulo";
  #location = {
  #  latitude = -23.539380;
  #  longitude = -46.652530;
  #};

  # Only install the docs I use
  documentation = {
    enable = true; # documentation of packages
    nixos.enable = false; # nixos documentation
    man.enable = true; # man pages and the man command
    info.enable = false; # info pages and the info command
    doc.enable = false;
  };

  environment = {
    # Eject nano and perl from the system
    defaultPackages = with pkgs;
      lib.mkForce [ gitMinimal home-manager micro rsync ];
    systemPackages = with pkgs; [ pciutils psmisc unzip usbutils duf htop ];
    variables = {
      EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };
  };

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

    # Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
    enableDefaultFonts = false;

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = [ "Source Serif" ];
        sansSerif = [ "Work Sans" "Fira Sans" "FiraGO" ];
        monospace = [ "FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono" ];
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

  # Use passed hostname to configure basic networking
  networking = {
    extraHosts = ''
      192.168.1.50  nitro
      192.168.1.35  nitro
      192.168.1.230 air
      192.168.1.200 DietPi
      192.168.1.76  oldmac
    '';
    hostName = hostname;
    hostId = hostid;
    useDHCP = lib.mkDefault true;
  };

  ###################
  ### NixPackages ###
  ###################

  nixpkgs = {

    # You can add overlays here
    overlays = [
      # if you also want support for flakes
      #(self: super: {
      #  nix-direnv = super.nix-direnv.override { enableFlakes = true; };
      #})
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Allow unsupported packages to be built
      allowUnsupportedSystem = false;
      # Disable broken package
      allowBroken = false;
      # Disable if you don't want unfree packages
      allowUnfree = true;

      ### Allow old broken electron 
      permittedInsecurePackages = lib.singleton "electron-12.2.3";

      ### Android
      android_sdk.accept_license = true;

      # Accept the joypixels license
      joypixels.acceptLicense = true;
    };
  };

  #####################
  ### Nixos Configs ###
  #####################

  nix = {

    gc = {
      automatic = true;
      options = "--delete-older-than 5d";
      dates = "00:00";
    };

    extraOptions = ''
      log-lines = 15

      # Free up to 4GiB whenever there is less than 1GiB left.
      min-free = ${toString (1024 * 1024 * 1024)}
      # Free up to 4GiB whenever there is less than 512MiB left.
      #min-free = ${toString (512 * 1024 * 1024)}
      max-free = ${toString (4096 * 1024 * 1024)}
      #min-free = 1073741824 # 1GiB
      #max-free = 4294967296 # 4GiB
      #builders-use-substitutes = true
    '';

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    optimise = {
      automatic = true;
      dates = [ "00:00" "05:00" "12:00" "21:00" ];
    };
    package = pkgs.unstable.nix;
    #package = pkgs.nixFlakes;
    settings = {
      sandbox = "relaxed";
      auto-optimise-store = true;
      warn-dirty = false;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];

      # https://nixos.org/manual/nix/unstable/command-ref/conf-file.html
      keep-going = false;

      # Allow to run nix
      #allowed-users = [ "${username}" "wheel" ];
    };
  };

  programs = {
    command-not-found.enable = false;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_cursor_default block blink
        set fish_cursor_insert line blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual block
        set -U fish_color_autosuggestion brblack
        set -U fish_color_cancel -r
        set -U fish_color_command green
        set -U fish_color_comment brblack
        set -U fish_color_cwd brgreen
        set -U fish_color_cwd_root brred
        set -U fish_color_end brmagenta
        set -U fish_color_error red
        set -U fish_color_escape brcyan
        set -U fish_color_history_current --bold
        set -U fish_color_host normal
        set -U fish_color_match --background=brblue
        set -U fish_color_normal normal
        set -U fish_color_operator cyan
        set -U fish_color_param blue
        set -U fish_color_quote yellow
        set -U fish_color_redirection magenta
        set -U fish_color_search_match bryellow '--background=brblack'
        set -U fish_color_selection white --bold '--background=brblack'
        set -U fish_color_status red
        set -U fish_color_user brwhite
        set -U fish_color_valid_path --underline
        set -U fish_pager_color_completion normal
        set -U fish_pager_color_description yellow
        set -U fish_pager_color_prefix white --bold --underline
        set -U fish_pager_color_progress brwhite '--background=cyan'
      '';
      shellAbbrs = {
        # https://github.com/NixOS/nixpkgs/issues/191128#issuecomment-1246030417
        mkhostid = "head -c4 /dev/urandom | od -A none -t x4";

        # VM testing
        nixclone = "git clone --depth=1 https://github.com/JucaRei/nixos-configs $HOME/Zero/nix-config";
        nix-gc = "sudo nix-collect-garbage --delete-older-than 5d";
        rebuild-all = "sudo nix-collect-garbage --delete-older-than 14d && sudo nixos-rebuild switch --flake $HOME/Zero/nix-config && home-manager switch -b backup --flake $HOME/Zero/nix-config";
        rebuild-home = "home-manager switch -b backup --flake $HOME/Zero/nix-config";
        rebuild-host = "sudo nixos-rebuild switch --flake $HOME/Zero/nix-config";
        rebuild-lock = "pushd $HOME/Zero/nix-config && nix flake lock --recreate-lock-file && popd";
        rebuild-iso-console = "pushd $HOME/Zero/nix-config && nix build .#nixosConfigurations.iso-console.config.system.build.isoImage && popd";
        rebuild-iso-desktop = "pushd $HOME/Zero/nix-config && nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage && popd";
        nix-hash-sha256 = "nix-hash --flat --base32 --type sha256";
        #rebuild-home = "home-manager switch -b backup --flake $HOME/.setup";
        #rebuild-host = "sudo nixos-rebuild switch --flake $HOME/.setup";
        #rebuild-lock = "pushd $HOME/.setup && nix flake lock --recreate-lock-file && popd";
        #rebuild-iso = "pushd $HOME/.setup && nix build .#nixosConfigurations.iso.config.system.build.isoImage && popd";
      };
      shellAliases = {
        moon = "curl -s wttr.in/Moon";
        nano = "micro";
        open = "xdg-open";
        pubip = "curl -s ifconfig.me/ip";
        #pubip = "curl -s https://api.ipify.org";
        wttr = "curl -s wttr.in && curl -s v2.wttr.in";
        wttr-bas = "curl -s wttr.in/basingstoke && curl -s v2.wttr.in/basingstoke";
      };
    };
    #nano.syntaxHighlight = true;
    #nano.nanorc = ''
    #  set autoindent   # Auto indent
    #  set constantshow # Show cursor position at the bottom of the screen
    #  set fill 78      # Justify command (Ctrl+j) wraps at 78 columns
    #  set historylog   # Remember command history
    #  set multibuffer  # Allow opening multiple files (Alt+< and Alt+> to switch)
    #  set nohelp       # Remove the help bar from the bottom of the screen
    #  set nowrap       # Do not wrap text
    #  set quickblank   # Clear status messages after a single keystroke
    #  set regexp       # Enable regular expression mode for find (Ctrl+r to disable)
    #  set smarthome    # Home key jumps to first non-whitespace character
    #  set tabsize 4    # Insert 4 spaces per tab
    #  set tabstospaces # Tab key inserts spaces (Ctrl+t for verbatim mode)
    #  set numbercolor blue,black
    #  set statuscolor black,yellow
    #  set titlecolor black,magenta
    #  include "${pkgs.nano}/share/nano/extra/*.nanorc"
    #'';
  };

  systemd = {
    # Create dirs for home-manager
    tmpfiles.rules = [
      "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
      "d /mnt/snapshot/${username} 0755 ${username} users"
    ];

    # Reduce default service stop timeouts for faster shutdown
    extraConfig = ''
      DefaultTimeoutStopSec=15s
      DefaultTimeoutAbortSec=5s
    '';

    #services.nix-daemon = {
    #  environment = { TMPDIR = "/var/cache/nix"; };
    #  serviceConfig = {
    #    CacheDirectory = "nix";
    #    Nice = 19;
    #  };
    #};
  };
  system = {

    autoUpgrade.allowReboot = true;

    activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      '';

      # systemd's out-of-memory daemon
      #oomd = {
      #  enable = lib.mkDefault true;
      #  enableSystemSlice = true;
      #  enableUserServices = true;
      #};
    };
  };

  systemd.services = {
    # Workaround https://github.com/NixOS/nixpkgs/issues/180175
    NetworkManager-wait-online.enable = false;
    #systemd-udevd.restartIfChanged = false;
  };

  system.stateVersion = stateVersion;
}
