{ config, pkgs, nixpkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  # Adding missing dependencies
  nixpkgs.config.packageOverrides = pkgs: {
    steam =
      pkgs.steam.override { extraPkgs = pkgs: with pkgs; [ libgdiplus ]; };
  };

  # Java
  programs.java.enable = true;
  environment.systemPackages = with pkgs;
    [ (steam.override { withJava = true; }) ];
}
