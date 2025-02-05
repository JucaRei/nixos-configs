{pkgs, ...}: {
  programs.bat = {
    enable = true;
    config = {theme = "cyberpunk-neon";};
    themes = {
      cyberpunk-neon =
        builtins.readFile ./configs/bat/themes/cyberpunk-neon.tmTheme;
    };
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batgrep
      batman
      batpipe
      batwatch
      prettybat
    ];
  };
  systemd.user.services.bat-cache = {
    Unit.Description = "Build and update bat cache";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bat}/bin/bat cache --build";
    };
    Install.WantedBy = ["default.target"];
  };
}
