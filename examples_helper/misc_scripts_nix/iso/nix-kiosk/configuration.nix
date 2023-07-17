#Bootable NixOS USB stick for kiosk or demo usage
{ config
, lib
, pkgs
, ...
}:
with lib; {
  imports = [
    # ISO image
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
    # Hardware support similar to installer Live CD
    <nixpkgs/nixos/modules/profiles/all-hardware.nix>
    <nixpkgs/nixos/modules/installer/scan/detected.nix>
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  # ISO image configuration
  isoImage.isoName = "NixOS-${config.system.nixosLabel}-${pkgs.stdenv.system}.iso";
  isoImage.volumeID = substring 0 11 "NIXOS_ISO";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.appendToMenuLabel = "";

  # Newers available Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Silent boot
  boot.consoleLogLevel = 0;
  boot.loader.timeout = pkgs.lib.mkForce 0;

  # Network Manager
  networking.networkmanager.enable = true;

  # Kiosk user
  users.users.user = {
    isNormalUser = true;
    description = "User";
    home = "/home/user";
    extraGroups = [
      "audio"
      "input"
      "networkmanager"
      "video"
    ];
    uid = 1000;
  };
  security.sudo.enable = false;

  # Kiosk X11
  services.xserver.enable = true;
  services.xserver.config = ''
    Section "ServerFlags"
      Option  "DontVTSwitch"  "True"
    EndSection
  '';
  services.xserver.synaptics.enable = true;
  services.xserver.displayManager.auto.enable = true;
  services.xserver.displayManager.auto.user = "user";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.windowManager.default = "i3";
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.configFile = pkgs.writeText "config" ''
    set $mod Mod4

    new_window 1pixel
    for_window [class="Surf"] fullscreen

    exec --no-startup-id nm-applet
    exec surf -k "https://www.google.com/"
  '';

  environment.systemPackages = with pkgs; [
    surf
    i3status
    networkmanagerapplet
  ];
}
