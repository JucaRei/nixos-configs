{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../services/networkmanager.nix
    #../services/systemd-networkd.nix
  ];

  # Exclude the Epiphany browser
  environment = {
    pantheon.excludePackages = with pkgs.pantheon; [
      epiphany
      elementary-music
      elementary-photos
      elementary-videos
    ];

    # App indicator
    # - https://discourse.nixos.org/t/anyone-with-pantheon-de/28422
    # - https://github.com/NixOS/nixpkgs/issues/144045#issuecomment-992487775
    pathsToLink = ["/libexec"];

    # Add some elementary additional apps and include Yaru for syntax highlighting
    systemPackages = with pkgs; [
      appeditor # elementary OS menu editor
      #cipher # elementary OS text encoding/decoding
      #elementary-planner         # UNSTABLE: elementary OS planner with Todoist support
      evolutionWithPlugins # Email client
      formatter # elementary OS filesystem formatter
      gthumb # Image Viewer
      gnome.simple-scan
      monitor # elementary OS system monitor
      indicator-application-gtk3 # App Indicator
      libsForQt5.qtstyleplugins # Qt5 style plugins
      #inputs.nix-software-center.packages.${system}.nix-software-center
      #minder # elementary OS mind-mapping
      #monitor # elementary OS system monitor
      #nasc                       # UNSTABLE: elementary OS maths notebook
      #notes-up # elementary OS Markdown editor
      pantheon.sideload # elementary OS Flatpak installer
      tilix # Tiling terminal emulator
      #tootle # elementary OS Mastodon client
      #torrential # elementary OS torrent client
      yaru-theme
    ];

    # Required to coerce dark theme that works with Yaru
    # TODO: Set this in the user-session
    variables = lib.mkForce {
      QT_QPA_PLATFORMTHEME = "gnome";
      QT_STYLE_OVERRIDE = "Adwaita-Dark";
    };
  };

  # Add GNOME Disks and Pantheon Tweaks
  programs = {
    evolution.enable = true;
    gnome-disks.enable = true;
    pantheon-tweaks.enable = true;
    seahorse.enable = true;
  };

  services = {
    flatpak = {
      enable = true;
    };
    gnome.evolution-data-server.enable = true;
    pantheon.apps.enable = true;

    xserver = {
      enable = true;
      displayManager = {
        lightdm.enable = true;
        # Use GTK greeter as the Pantheon greeter is not working
        #lightdm.greeters.pantheon.enable = false;
        lightdm.greeters.pantheon.enable = true;
        #lightdm.greeters.gtk = {
        #  enable = true;
        #  cursorTheme.name = "elementary";
        #  cursorTheme.package = pkgs.pantheon.elementary-icon-theme;
        #  cursorTheme.size = 32;
        #  iconTheme.name = "Yaru-magenta-dark";
        #  iconTheme.package = pkgs.yaru-theme;
        #  theme.name = "Yaru-magenta-dark";
        #  theme.package = pkgs.yaru-theme;
        #  indicators = [
        #    "~session"
        #    "~host"
        #    "~spacer"
        #    "~clock"
        #    "~spacer"
        #    "~a11y"
        #    "~power"
        #  ];
        #  # https://github.com/Xubuntu/lightdm-gtk-greeter/blob/master/data/lightdm-gtk-greeter.conf
        #  extraConfig = ''
        #    # background = Background file to use, either an image path or a color (e.g. #772953)
        #    font-name = Work Sans 12
        #    xft-antialias = true
        #    xft-dpi = 96
        #    xft-hintstyle = slight
        #    xft-rgba = rgb
        #
        #    active-monitor = #cursor
        #    # position = x y ("50% 50%" by default)  Login window position
        #    # default-user-image = Image used as default user icon, path or #icon-name
        #    hide-user-image = false
        #    round-user-image = false
        #    highlight-logged-user = true
        #    panel-position = top
        #    clock-format = %a, %b %d  %H:%M
        #  '';
      };

      desktopManager = {
        pantheon = {
          enable = true;
          extraWingpanelIndicators = with pkgs; [
            monitor
            wingpanel-indicator-ayatana
          ];
        };
      };
    };
  };

  # App indicator
  # - https://github.com/NixOS/nixpkgs/issues/144045#issuecomment-992487775
  systemd.user.services.indicatorapp = {
    description = "indicator-application-gtk3";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    serviceConfig = {
      ExecStart = "${pkgs.indicator-application-gtk3}/libexec/indicator-application/indicator-application-service";
    };
  };
}
