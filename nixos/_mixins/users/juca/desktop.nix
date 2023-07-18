{ pkgs, lib, desktop, ... }: {
  imports = [
    #../../desktop/apps/video-editing/obs-studio.nix
    #../../virt/quickemu.nix
    #../../virt/virt-manager.nix
    #../../desktop/apps/browsers/brave.nix
    #../../desktop/apps/browsers/firefox.nix
    #../../desktop/evolution.nix
    #../../desktop/apps/browsers/google-chrome.nix
    #../../desktop/apps/browsers/microsoft-edge.nix
    #../../desktop/apps/browsers/opera.nix
    #../../desktop/apps/terminals/tilix.nix
    #../../desktop/vivaldi.nix

  ] ++ lib.optional
    (builtins.pathExists (../.. + "/desktop/${desktop}-apps.nix"))
    ../../desktop/${desktop}-apps.nix
  ++ lib.optional (builtins.isString desktop)
    (../.. + "/desktop/apps/browsers/firefox.nix");

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
