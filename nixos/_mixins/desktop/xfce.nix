{pkgs, ...}: {
  imports = [
    ./configs/qt-style.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      drawing
      mpv
      elementary-xfce-icon-theme
      evince
      font-manager
      gnome.file-roller
      libqalculate
      pavucontrol
      qalculate-gtk
      wmctrl
      xclip
      xdotool
      xorg.xev
      xsel
      xwinmosaic
      zuki-themes
    ];
  };

  programs = {
    gnome-disks.enable = true;
    seahorse.enable = true;
    nm-applet.enable = true;
    system-config-printer.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-media-tags-plugin
        thunar-volman
      ];
    };
  };

  #security.pam.services.gdm.enableGnomeKeyring = true;

  services = {
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
    system-config-printer.enable = true;
    xserver = {
      enable = true;
      displayManager = {
        defaultSession = "xfce";
        lightdm = {
          enable = true;
          greeters = {
            gtk = {
              theme.package = pkgs.nordic;
              theme.name = "Nordic";
            };
          };
        };
      };
      desktopManager = {
        xfce = {
          enable = true;
          enableXfwm = true;
          enableScreensaver = true;
        };
      };
    };
  };

  sound = {
    #enable = true;
    mediaKeys.enable = true;
  };
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];
}
