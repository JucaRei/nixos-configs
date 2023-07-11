{ desktop, pkgs, lib, ... }: {
  imports = [
    ../services/cups.nix
    ../hardware/gfx-intel.nix
    ../services/sane.nix
    ../services/dynamic-timezone.nix
  ] ++ lib.optional (builtins.pathExists (./. + /${desktop}.nix))
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
}
