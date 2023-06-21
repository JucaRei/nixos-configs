{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    firefox
    thunderbird
    discord
    mullvad-vpn
    steam-run
  ];
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  fonts.fontDir.enable = true;

  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      firefox = {
        executable = "${pkgs.lib.getBin pkgs.firefox}/bin/firefox";
        profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
      };
      thunderbird = {
        executable = "${pkgs.lib.getBin pkgs.thunderbird}/bin/thunderbird";
        profile = "${pkgs.firejail}/etc/firejail/thunderbird.profile";
      };
      discord = {
        executable = "${pkgs.lib.getBin pkgs.discord}/bin/discord";
        profile = "${pkgs.firejail}/etc/firejail/discord.profile";
      };
    };
  };

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
}
