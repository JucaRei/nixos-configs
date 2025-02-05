{ desktop, pkgs, lib, ... }: {
  imports = [ ../services/cups.nix ../services/sane.nix ]
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix"))
    ./${desktop}.nix;

  boot = {
    kernelParams = [ "quiet" "vt.global_cursor_default=0" "mitigations=off" ];
    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };

  # X11 automation
  environment.systemPackages = with pkgs; [
    wmctrl # Terminal X11 automation
    xdotool # Terminal X11 automation
    ydotool # Terminal *all-the-things* automation
  ];

  programs.dconf.enable = true;

  # Disable xterm
  services.xserver = {
    excludePackages = [ pkgs.xterm ];
    desktopManager.xterm.enable = false;
  };
}
