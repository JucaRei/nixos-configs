{ pkgs, lib, desktop, ... }: {
  imports = [
    #../../desktop/obs-studio.nix
    #../../virt/quickemu.nix
    #../../virt/virt-manager.nix
    #../../desktop/brave.nix
    ../../desktop/apps/browsers/firefox.nix
    #../../desktop/evolution.nix
    #../../desktop/google-chrome.nix
    #../../desktop/microsoft-edge.nix
    #../../desktop/obs-studio.nix
    #../../desktop/opera.nix
    #../../desktop/tilix.nix
    #../../desktop/vivaldi.nix

  ] ++ lib.optional (builtins.pathExists (./. + "/${desktop}-apps.nix"))
    ./${desktop}-apps.nix;

  environment.systemPackages = with pkgs; [
    #authy
    #cider
    #gimp-with-plugins
    gnome.dconf-editor
    gnome.gnome-clocks
    #gnome.gnome-sound-recorder
    #irccloud
    #inkscape
    libreoffice
    keybase-gui
    #maestral-gui
    #netflix
    #meld
    #pavucontrol
    rhythmbox
    #shotcut
    #slack

    # Fast moving apps use the unstable branch
    #unstable.discord
    #unstable.gitkraken
    #unstable.tdesktop
    unstable.vscode-fhs
    #unstable.fluffychat
    #unstable.zoom-us
    #unstable.wavebox
  ];
}
