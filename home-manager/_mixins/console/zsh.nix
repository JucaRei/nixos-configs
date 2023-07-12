{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
  home = {
    packages = with pkgs; [ zsh ];
    file = let
      files = [
        "/configs/zsh/kubectl.zsh"
        "/configs/zsh/prompt.zsh"
        "/configs/zsh/git.zsh"
      ];
      #src = builtins.filterSource (p: t: builtins.elem p files) ./.;
      src = builtins.filterSource (p: t: builtins.elem p files) /.;
    in { "${config.xdg.configHome}/.zshrc".text = builtins.readFile src; };
  };
}
