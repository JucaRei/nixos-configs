{ config, pkgs, ... }:
#let
#  files = [ ./kubectl.zsh ./prompt.zsh ./git.zsh ];
#  src = builtins.filterSource (p: t: builtins.elem (/. + p) files) ./.;
#in 
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
  home = {
    packages = with pkgs; [ zsh ];
    file = {
      "${config.xdg.configHome}/.zshrc".text = [
        (builtins.readFile "\n" ./kubectl.zsh)
        (builtins.readFile "\n" ./git.zsh)
        (builtins.readFile "\n" ./prompt.zsh)
      ];
    };
  };
}
