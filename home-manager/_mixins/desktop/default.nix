{
  config,
  desktop,
  pkgs,
  ...
}: {
  imports = [
    #../apps//audio-recorder.nix
    ../apps/celluloid.nix
    ../apps/dconf-editor.nix
    ../apps/emote.nix
    #../apps/gitkraken.nix
    #../apps/gnome-sound-recorder.nix
    #../apps/meld.nix
    ../apps/rhythmbox.nix
    #../apps/tilix.nix
    #../apps/samba.nix
    (./. + "/${desktop}.nix")
  ];

  home.file = {
    "${config.xdg.configHome}/autostart/enable-flathub.desktop".text = "\n\n      [Desktop Entry]\n      Name=Enable Flathub\n      Comment=Enable Flathub\n      Type=Application\n      Exec=${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo\n      Categories=\n      Terminal=false\n      NoDisplay=true\n      StartupNotify=false";
  };

  xresources.properties = {
    "XTerm*background" = "#121214";
    "XTerm*foreground" = "#c8c8c8";
    "XTerm*cursorBlink" = true;
    "XTerm*cursorColor" = "#FFC560";
    "XTerm*boldColors" = false;

    #Black + DarkGrey
    "*color0" = "#141417";
    "*color8" = "#434345";
    #DarkRed + Red
    "*color1" = "#D62C2C";
    "*color9" = "#DE5656";
    #DarkGreen + Green
    "*color2" = "#42DD76";
    "*color10" = "#A1EEBB";
    #DarkYellow + Yellow
    "*color3" = "#FFB638";
    "*color11" = "#FFC560";
    #DarkBlue + Blue
    "*color4" = "#28A9FF";
    "*color12" = "#94D4FF";
    #DarkMagenta + Magenta
    "*color5" = "#E66DFF";
    "*color13" = "#F3B6FF";
    #DarkCyan + Cyan
    "*color6" = "#14E5D4";
    "*color14" = "#A1F5EE";
    #LightGrey + White
    "*color7" = "#c8c8c8";
    "*color15" = "#e9e9e9";
    "XTerm*faceName" = "FiraCode Nerd Font:size=13:style=Medium:antialias=true";
    "XTerm*boldFont" = "FiraCode Nerd Font:size=13:style=Bold:antialias=true";
    "XTerm*geometry" = "132x50";
    "XTerm.termName" = "xterm-256color";
    "XTerm*locale" = false;
    "XTerm*utf8" = true;

    # set cursor size and dpi for 4k monitor
    #"Xcursor.size" = 16;
    #"Xft.dpi" = 172;

    # set for 1080p
    #"Xcursor.size" = 16;
    #"Xft.dpi" = 96;
  };
}
