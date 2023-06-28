{pkgs, ...}: {
  imports = [
    # ../../desktop/apps/obs-studio.nix
    ../../boxes/quickemu.nix
    ../../boxes/virt-manager.nix
  ];

  environment.systemPackages = with pkgs; [
    #authy
    #cider
    #gimp-with-plugins
    gnome.dconf-editor
    #inkscape
    libreoffice
    #maestral-gui
    #netflix
    #meld
    pavucontrol
    rhythmbox
    #shotcut
    #slack

    # Fast moving apps use the unstable branch
    #unstable.discord
    #unstable.gitkraken
    #unstable.tdesktop
    unstable.vscode-fhs
    #unstable.zoom-us
    #unstable.wavebox
  ];
}
