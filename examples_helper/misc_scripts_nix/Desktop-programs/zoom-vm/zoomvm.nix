# NixOS Configuration for Running Zoom in a VM, where it belongs, because you have to...
# INSTRUCTIONS:
# 1. Follow the installation instructions at
#    https://nixos.org/nixos/manual/index.html until
#    /mnt/etc/nixos/configuration.nix is edited
# 2. Replace that file with this one:
#    -> curl -L -o /mnt/etc/nixos/configuration.nix https://go.nzbr.de/zoomvm
# 3. You will need to edit this configuration if you want a locale other than
#    german (i18n and xserver.locale) or not use UEFI (boot.loader)
# 4. Run `nix-env -i git` to install git on the live system (may take some time)
# 5. Run nixos-install
# 6. Reboot
# 7. If zoom didn't automatically open upon first booting the VM,
#    you have to open a terminal (either a TTY or by pressing Ctrl+T and then c)
#    and run `sudo nixos-rebuild boot`. After a reboot it should work
# NOTE: The default password for the user `zoom` is `123456`
{
  config,
  pkgs,
  ...
}: let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "b78b5fa4a073dfcdabdf0deb9a8cfd56050113be"; # CHANGEME
    ref = "release-19.09";
  };
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernelParams = ["net.ifnames=0" "biosdevname=0"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "zoom"; # Define your hostname.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.eth0.useDHCP = true;

    # Open ports in the firewall.
    firewall = {
      enable = true;
      # package = pkgs.iptables-nftables-compat; # Does not work with my firewall.nix (proably not stable yet?)

      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";
    defaultLocale = "de_DE.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # List services that you want to enable:
  services = {
    spice-vdagentd.enable = true;
    qemuGuest.enable = true;

    xserver = {
      enable = true;
      layout = "de";
      videoDrivers = ["qxl" "cirrus" "vmware" "vesa" "modesetting"];

      windowManager = {
        default = "ratpoison"; # Deprecated
        ratpoison.enable = true;
        # openbox.enable = true;
        # i3 = {
        #   enable = true;
        #   package = pkgs.i3-gaps;
        # };
      };

      desktopManager.default = "none";
      displayManager = {
        # defaultSession = "ratpoison"; # Does not work currently
        lightdm = {
          enable = true;
          greeter.enable = false;

          autoLogin = {
            enable = true;
            timeout = 0;
            user = "zoom";
          };
        };
      };
    };

    compton.enable = true;
    openssh = {
      enable = true;
      permitRootLogin = "yes";
    };
  };

  virtualisation = {
    virtualbox.guest.enable = true;
    vmware.guest.enable = true;
  };

  programs = {
    bash.promptInit = ''
      # Fix missing kitty terminfo
      if [ "$TERM" == "xterm-kitty" ]; then
        export TERM=xterm-256color
      fi

      # Provide a nice prompt if the terminal supports it.
      if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
        PROMPT_COLOR="1;31m"
        let $UID && PROMPT_COLOR="1;32m"
        if [ -n "$INSIDE_EMACS" -o "$TERM" == "eterm" -o "$TERM" == "eterm-color" ]; then
          # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
          PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
        else
          PS1="\n\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
        fi
        if test "$TERM" = "xterm"; then
          PS1="\[\033]2;\h:\u:\w\007\]$PS1"
        fi
      fi

      neofetch
    '';
  };

  users.users.zoom = {
    createHome = true;
    initialHashedPassword = "$6$ah4q31hZlNa$zh4FzYEYHOFf.R6MG.GVgR7MyrKqb.ueXNUymResXIYeVC2IbcZkQ3IhZwv.whTm1VOox8W2WolHqF4Im6f7i1"; # 123456
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
  };

  environment.etc = {};

  home-manager.users.zoom = {
    home.file.ratpoisonrc = {
      target = ".ratpoisonrc";
      text = ''
        startup_message off
        bind c exec lxterminal

        exec spice-vdagent
        exec zoom-us
      '';
    };
  };

  # For obvious reasons:
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    file
    vim
    curl
    neofetch
    zoom-us
    git
    lxterminal
    killall
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
