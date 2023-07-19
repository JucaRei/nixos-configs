# NOTE: This is the minimum Pantheon, included in the live .iso image
# For actuall installs pantheon-apps.nix is also included
{pkgs, ...}: {
  imports = [
    ./configs/qt-style.nix
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
  };
  services = {
    #pantheon.apps.enable = true;

    xserver = {
      enable = true;
      displayManager = {
        defaultSession = "pantheon";
        #defaultSession = "xfce+bspwm";
        #defaultSession = "none+bspwm";
        lightdm = {
          enable = true;
          greeters.pantheon.enable = true;
        };
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
  systemd.user.services.indicator-application-service = {
    description = "indicator-application-service";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    serviceConfig = {
      ExecStart = "${pkgs.indicator-application-gtk3}/libexec/indicator-application/indicator-application-service";
    };
  };
}
