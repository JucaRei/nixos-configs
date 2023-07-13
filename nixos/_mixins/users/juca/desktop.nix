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

  ] ++ lib.optional (builtins.pathExists (../.. + "/desktop/${desktop}-apps.nix")) ../../desktop/${desktop}-apps.nix;

  environment.systemPackages = with pkgs; [
    #audio-recorder
    #authy
    #chatterino2
    #cider
    #gimp-with-plugins
    gnome.dconf-editor
    gnome.gnome-clocks
    #gnome.gnome-sound-recorder
    pick-colour-picker
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
    #zoom-us

    # Fast moving apps use the unstable branch
    #unstable.discord
    #unstable.gitkraken
    #unstable.tdesktop
    unstable.vscode-fhs
    #unstable.fluffychat
    #unstable.wavebox
  ];
}
