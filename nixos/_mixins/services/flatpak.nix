{pkgs, ...}: {
  services.flatpak.enable = true;
  xdg.portal = {
    xdgOpenUsePortal = true;
    enable = true;
    #extraPortals = with pkgs; [
    #  xdg-desktop-portal-gtk
    #  xdg-desktop-portal-gnome
    #  xdg-desktop-portal-kde
    #  pantheon.xdg-desktop-portal-pantheon
    #];
  };
}
