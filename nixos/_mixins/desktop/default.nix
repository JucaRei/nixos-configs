{
  desktop,
  pkgs,
  username,
  ...
}: {
  imports = [
    #../services/cups.nix
    ../services/flatpak.nix
    ../services/sane.nix
    ../services/dynamic-timezone.nix
    (./. + "/${desktop}.nix")
  ];

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

  security.sudo = {
    enable = false;
    # Stops sudo from timing out.
    extraConfig = ''
      ${username} ALL=(ALL) NOPASSWD:ALL
      Defaults env_reset,timestamp_timeout=-1
    '';
    execWheelOnly = true;
  };

  security.doas = {
    enable = true;
    extraConfig = ''
      permit nopass :wheel
    '';
  };
}
