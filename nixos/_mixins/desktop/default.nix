{
  desktop,
  pkgs,
  username,
  lib,
  ...
}: {
  imports =
    [
      ../services/cups.nix
      ../services/flatpak.nix
      #./obs-studio.nix
      #./firefox.nix
      ../services/sane.nix
      ../services/dynamic-timezone.nix
      # (./. + "/${desktop}.nix")
    ]
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;
  #++ lib.optional (builtins.pathExists (./. + "./desktops/${desktop}.nix")) "./desktops/${desktop}.nix";
  #++ lib.optional (builtins.pathExists "./windowmanagers/${desktop}.nix") ./windowmanagers/${desktop}.nix;

  boot.kernelParams = ["quiet" "splash" "net.ifnames=0" "mem_sleep_default=deep"];
  boot.plymouth = {
    enable = true;
    theme = "breeze";
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override {fonts = ["FiraCode" "UbuntuMono"];})
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
        serif = ["Work Sans" "Joypixels"];
        sansSerif = ["Work Sans" "Joypixels"];
        monospace = ["FiraCode Nerd Font Mono"];
        emoji = ["Joypixels"];
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

  # Disable xterm
  services.xserver.excludePackages = [pkgs.xterm];
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
