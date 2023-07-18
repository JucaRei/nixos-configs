{ config, lib, ... }:
with lib;
with builtins;
let cfg = config.sys.desktop;
in {
  config = mkIf (cfg.desktop == "budgie") {
    services = {
      xserver = {
        enable = true;
        displayManager = {
          gdm = {
            enable = true;
            inherit (cfg) wayland;
            inherit (cfg) autoSuspend;
          };
        };
        desktopManager = { budgie = { enable = true; }; };
      };
    };
    hardware = { opengl = { enable = true; }; };
    programs = { xwayland = { enable = true; }; };
    security = { rtkit = { enable = true; }; };
  };
}
