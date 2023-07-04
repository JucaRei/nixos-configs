{ desktop, pkgs, username, lib, ... }: {
  imports = [
    ../services/cups.nix
    ../services/flatpak.nix
    ../services/sane.nix
    ../services/dynamic-timezone.nix
  ] ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;

  boot.kernelParams = [
    # The 'splash' arg is included by the plymouth option
    "quiet"
    "loglevel=3"
    "rd.udev.log_priority=3"
    "vt.global_cursor_default=0"
    "mitigations=off"
    "zswap.enabled=1"
    "zswap.compressor=lz4hc"
    "zswap.max_pool_percent=20"
    "zswap.zpool=z3fold"
    "net.ifnames=0"
    "mem_sleep_default=deep"
  ];
  boot.plymouth = {
    enable = true;
    theme = "breeze";
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "UbuntuMono" ]; })
      joypixels
      liberation_ttf
      ubuntu_font_family
      work-sans
    ];

    # use fonts specified by user rather than default ones
    enableDefaultFonts = false;

    fontconfig = {
      antialias = true;
      cache32Bit = true;
      defaultFonts = {
        serif = [ "Work Sans" "Joypixels" ];
        sansSerif = [ "Work Sans" "Joypixels" ];
        monospace = [ "FiraCode Nerd Font Mono" ];
        emoji = [ "Joypixels" ];
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

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = [ ] ++ lib.optionals (pkgs.system == "x86_64-linux")
        (with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
        ]);
    };
  };

  programs = {
    dconf.enable = true;
    # Chromium is enabled by default with sane defaults.
    firefox = { enable = false; };
  };

  # Accept the joypixels license
  nixpkgs.config.joypixels.acceptLicense = true;

  # Disable xterm
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.desktopManager.xterm.enable = false;

  security.sudo = {
    enable = true;
    # Stops sudo from timing out.
    extraConfig = ''
      ${username} ALL=(ALL) NOPASSWD:ALL
      Defaults env_reset,timestamp_timeout=-1
    '';
    execWheelOnly = true;
  };

  security.doas = {
    enable = false;
    extraConfig = ''
      permit nopass :wheel
    '';
  };
}
