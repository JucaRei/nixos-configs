{ desktop, pkgs, username, lib, hostname, ... }: {
  imports = [
    ../services/cups.nix
    ../services/flatpak.nix
    ../hardware/gfx-intel.nix
    ../services/sane.nix
    ../services/dynamic-timezone.nix
  ] ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix"))
    ./${desktop}.nix;

  boot = {
    kernelParams = [ "quiet" "vt.global_cursor_default=0" "mitigations=off" ];
  };

  programs.dconf.enable = true;

  # Disable xterm
  services.xserver = {
    excludePackages = [ pkgs.xterm ];
    desktopManager.xterm.enable = false;
  };

  security.sudo = {
    enable = true;
    # Stops sudo from timing out.
    extraConfig = ''
      ${username} ALL=(ALL) NOPASSWD:ALL
      Defaults env_reset,timestamp_timeout=-1
    '';
    execWheelOnly = true;
    # wheelNeedsPassword = false;
  };

  security.doas = {
    enable = false;
    extraConfig = ''
      permit nopass :wheel
    '';
  };
}
