{pkgs, ...}: {
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.libinput.enable = true;
  services.xserver.displayManager.startx.enable = true;

  environment = {
    variables = {
      XDG_DESKTOP_DIR = "$HOME/";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_BIN_HOME = "$HOME/.local/bin";
    };
    systemPackages = with pkgs; [
      pkgs.sqlite
      pkgs.pfetch
      pkgs.cmatrix
      pkgs.asciiquarium
    ];
    extraInit = ''
      export XAUTHORITY=/tmp/Xauthority
      export xserverauthfile=/tmp/xserverauth
      [ -e ~/.Xauthority ] && mv -f ~/.Xauthority "$XAUTHORITY"
      [ -e ~/.serverauth.* ] && mv -f ~/.serverauth.* "$xserverauthfile"
    '';
  };

  services.picom.enable = true;
  services.printing.enable = true;

  fonts.fonts = with pkgs; [iosevka-bin emacs-all-the-icons-fonts];
}
