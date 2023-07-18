{pkgs, ...}: {
  environment.systemPackages = with pkgs; [xorg.xhost];
  #shellInit = ''
  #  [ -n "$DISPLAY" ] && xhost +si:localuser:$USER || true
  #'';
}
