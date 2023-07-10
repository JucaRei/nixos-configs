{ pkgs, ... }: {

  imports = [
    #./qt-style.nix 
    ./apps/browsers/firefox.nix
    ../services/networkmanager.nix
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

  security.pam.services.gdm.enableGnomeKeyring = true;

  services = {
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
    system-config-printer.enable = true;
    xserver = {
      enable = true;
      excludePackages = with pkgs; [ xterm ];
      displayManager = {
        lightdm = {
          enable = true;
          greeters = {
            slick = {
              enable = true;
              theme.name = "Adwaita";
            };
          };
        };
      };
      desktopManager = { xfce.enable = true; };
    };
  };

  sound = {
    #enable = true;
    mediaKeys.enable = true;
  };
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
}
