{ pkgs, ... }: {

  imports = [
    #./qt-style.nix
    ./apps/browsers/firefox.nix
    ../services/networkmanager.nix
  ];

  programs = {
    dconf.enable = true;
    kdeconnect = {
      # For GSConnect
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };

  services = {
    xserver = {
      enable = true;

      displayManager.gdm = {
        enable = true; # Display Manager
      };
      desktopManager.gnome = {
        enable = true; # Window Manager
      };
    };
    udev.packages = with pkgs; [
      gnome.gnome-settings-daemon
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      # Packages installed
      gnome.dconf-editor
      gnome.gnome-tweaks
      gnome.adwaita-icon-theme
      tilix
    ];
    gnome.excludePackages = (with pkgs; [
      # Gnome ignored packages
      gnome-tour
    ]) ++ (with pkgs.gnome; [
      gedit # text editor
      epiphany # web-browser
      geary # email client
      gnome-characters
      totem # video player
      tali
      iagno
      hitori
      atomix
      yelp
      gnome-contacts
      gnome-initial-setup
      gnome.gnome-terminal # remove default terminal
    ]);
  };
}
