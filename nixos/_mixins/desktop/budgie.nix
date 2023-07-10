{ pkgs, username, ... }: {
  imports = [
    ./qt-style.nix
    ./apps/browsers/firefox.nix
    ../services/networkmanager.nix
  ];

  # Exclude MATE themes. Yaru will be used instead.
  # Don't install mate-netbook or caja-dropbox
  environment = {
    mate.excludePackages = with pkgs.mate; [
      caja-dropbox
      eom
      mate-themes
      mate-netbook
      mate-icon-theme
      mate-backgrounds
      mate-icon-theme-faenza
    ];

    # Add some packages to complete the MATE desktop
    systemPackages = with pkgs; [
      celluloid
      gnome.gucharmap
      gnome-firmware
      gnome.simple-scan
      gthumb
      networkmanagerapplet
    ];
  };

  # Enable some programs to provide a complete desktop
  programs = {
    light.enable = true;
    gnome-disks.enable = true;
    nm-applet.enable = true;
    seahorse.enable = true;
    system-config-printer.enable = true;
  };

  # Enable services to round out the desktop
  services = {
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
    system-config-printer.enable = true;
    xserver = {
      enable = true;
      displayManager = {
        #gdm = {
        #  enable = true;
        #  wayland = true;
        #};
        lightdm.greeters.slick.enable = true;
        autoLogin = {
          enable = false;
          #enable = true;
          #user = "${username}";
        };
      };

      desktopManager = { budgie.enable = true; };
    };
  };
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gnome ];
  security.pam.services = { budgie-screensaver.allowNullPassword = true; };

}
