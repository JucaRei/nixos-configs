{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
  home = {
    packages = with pkgs; [ zsh ];
    file = let
      files = [ ./kubectl.zsh ./prompt.zsh ];
      #src = builtins.filterSource (p: t: builtins.elem p files) ./.;
      src = builtins.filterSource (p: t: builtins.elem p files) ./configs/zsh.;
    in { "${config.xdg.configHome}/.zshrc".text = builtins.readFile src; };
  };
}
