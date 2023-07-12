{ config, pkgs, ... }:
#let
#  files = [ ./kubectl.zsh ./prompt.zsh ./git.zsh ];
#  src = builtins.filterSource (p: t: builtins.elem (/. + p) files) ./.;
#in 

let
  filter = path: type:
    builtins.elem (/. + path) [ ./git.zsh ./kubectl.zsh ./prompt.zsh ];
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
  home = {
    packages = with pkgs; [ zsh ];
    file = {
      "${config.xdg.configHome}/.zshrc".text = builtins.readFile filter;
    };
  };
}
