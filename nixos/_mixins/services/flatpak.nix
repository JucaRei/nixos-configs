{ pkgs, ... }: {
  services.flatpak.enable = true;
  xdg.portal = {
    #xdgOpenUsePortal = true;
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
}
