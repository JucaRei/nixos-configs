{
  desktop,
  pkgs,
  ...
}: {
  imports = [
    ../services/cups.nix
    ../services/flatpak.nix
    ../services/sane.nix
    ../services/dynamic-timezone.nix
    (./. + "/${desktop}.nix")
  ];

  boot.kernelParams = ["quiet" "net.ifnames=0" "mem_sleep_default=deep"];
  boot.plymouth.enable = true;

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
}
