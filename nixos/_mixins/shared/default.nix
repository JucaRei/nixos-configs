{ pkgs, username, lib, ... }: {
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
    initrd = { verbose = false; };
    consoleLogLevel = 0;
    kernelModules = [ "vhost_vsock" "kvm-intel" "tcp_bbr" ];
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
        # https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
        "kernel.sysrq" = 1;
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "cake";
        #"net.core.default_qdisc" = "fq";

        # Bypass hotspot restrictions for certain ISPs
        "net.ipv4.ip_default_ttl" = 65;
      };
    };
  };

  ###################
  ### Console tty ###
  ###################

  console = {
    keyMap = if (builtins.isString == "nitro") then "br-abnt2" else "us";
    earlySetup = true;
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    colors = [
      "1b161f"
      "ff5555"
      "54c6b5"
      "d5aa2a"
      "bd93f9"
      "ff79c6"
      "8be9fd"
      "bfbfbf"

      "1b161f"
      "ff6e67"
      "5af78e"
      "ffce50"
      "caa9fa"
      "ff92d0"
      "9aedfe"
      "e6e6e6"
    ];
    packages = with pkgs; [ tamzen ];
  };

  services.getty.greetingLine = lib.mkForce "\\l";
  services.getty.helpLine = lib.mkForce ''
    Type `i' to print system information.

    .     .       .  .   . .   .   . .    +  .
      .     .  :     .    .. :. .___---------___.
           .  .   .    .  :.:. _".^ .^ ^.  '.. :"-_. .
        .  :       .  .  .:../:            . .^  :.:\.
            .   . :: +. :.:/: .   .    .        . . .:\
     .  :    .     . _ :::/:               .  ^ .  . .:\
      .. . .   . - : :.:./.                        .  .:\
      .      .     . :..|:                    .  .  ^. .:|
        .       . : : ..||        .                . . !:|
      .     . . . ::. ::\(                           . :)/
     .   .     : . : .:.|. ######              .#######::|
      :.. .  :-  : .:  ::|.#######           ..########:|
     .  .  .  ..  .  .. :\ ########          :######## :/
      .        .+ :: : -.:\ ########       . ########.:/
        .  .+   . . . . :.:\. #######       #######..:/
          :: . . . . ::.:..:.\           .   .   ..:/
       .   .   .  .. :  -::::.\.       | |     . .:/
          .  :  .  .  .-:.":.::.\             ..:/
     .      -.   . . . .: .:::.:.\.           .:/
    .   .   .  :      : ....::_:..:\   ___.  :/
       .   .  .   .:. .. .  .: :.:.:\       :/
         +   .   .   : . ::. :.:. .:.|\  .:/|
         .         +   .  .  ...:: ..|  --.:|
    .      . . .   .  .  . ... :..:.."(  ..)"
     .   .       .      :  .   .: ::/  .  .::\
  '';

  #######################
  ### Default Locales ###
  #######################

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

    earlyoom = { enable = lib.mkDefault false; };

    irqbalance = { enable = true; };

    fstrim = {
      enable = true; # ## ssd's
    };

    dbus = { implementation = lib.mkDefault "broker"; };

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

  ########################
  ### Default Timezone ###
  ########################

  time.timeZone = lib.mkDefault "America/Sao_Paulo";
  #location = {
  #  latitude = -23.539380;
  #  longitude = -46.652530;
  #};

  #############
  ### Fonts ###
  #############

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override {
        fonts =
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/shas.nix
          [ "FiraCode" "SourceCodePro" "UbuntuMono" "Iosevka" "IBMPlexMono" ];
      })
      fira
      fira-go
      joypixels
      liberation_ttf
      noto-fonts-emoji # emoji
      source-serif
      ubuntu_font_family
      work-sans
      siji # https://github.com/stark/siji
      ipafont # display jap symbols like シートベルツ in polybar
      source-code-pro
      terminus_font
      source-sans-pro
      roboto
      cozette
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

  #############################
  ### Fish as default Shell ###
  #############################

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
        nixclone =
          "git clone --depth=1 https://github.com/JucaRei/nixos-configs $HOME/Zero/nix-config";
        nix-gc = "sudo nix-collect-garbage --delete-older-than 5d";
        #rebuild-all = "sudo nix-collect-garbage --delete-older-than 14d && sudo nixos-rebuild switch --flake $HOME/Zero/nix-config && home-manager switch -b backup --flake $HOME/Zero/nix-config";
        rebuild-all =
          "sudo nix-collect-garbage --delete-older-than 5d && sudo nixos-rebuild boot --flake $HOME/Zero/nix-config && home-manager switch -b backup --flake $HOME/Zero/nix-config && sudo reboot";
        rebuild-home =
          "home-manager switch -b backup --flake $HOME/Zero/nix-config";
        rebuild-host =
          "sudo nixos-rebuild switch --flake $HOME/Zero/nix-config";
        rebuild-lock =
          "pushd $HOME/Zero/nix-config && nix flake lock --recreate-lock-file && popd";
        rebuild-iso-console =
          "pushd $HOME/Zero/nix-config && nix build .#nixosConfigurations.iso-console.config.system.build.isoImage && popd";
        rebuild-iso-desktop =
          "pushd $HOME/Zero/nix-config && nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage && popd";
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
        wttr-bas =
          "curl -s wttr.in/basingstoke && curl -s v2.wttr.in/basingstoke";
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

  #########################################
  ### Default environment for all hosts ###
  #########################################

  environment = {
    # Eject nano and perl from the system
    defaultPackages = with pkgs;
      lib.mkForce [ gitMinimal home-manager micro rsync ];
    systemPackages = with pkgs; [
      pciutils
      psmisc
      unzip
      usbutils
      duf
      htop
      font-manager
    ];
    variables = {
      EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };
  };

  ####################################
  ### Sytemd configs for all hosts ###
  ####################################

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

    ########################
    ### cache nix folder ###
    ########################

    services.nix-daemon = {
      environment = { TMPDIR = "/var/cache/nix"; };
      serviceConfig = {
        CacheDirectory = "nix";
        Nice = 19;
      };
    };
  };
  system = {
    autoUpgrade.allowReboot = true;

    activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      '';
    };
    ##systemd's out-of-memory daemon
    oomd = {
      enable = lib.mkDefault true;
      enableSystemSlice = true;
      enableUserServices = true;
    };
  };

  systemd.services = {
    # Workaround https://github.com/NixOS/nixpkgs/issues/180175
    NetworkManager-wait-online.enable = false;
    #systemd-udevd.restartIfChanged = false;
  };
}
