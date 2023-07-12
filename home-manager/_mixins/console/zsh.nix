{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
  home = {
    packages = with pkgs; [ zsh ];
    file = {
      "${config.xdg.configHome}/.zshrc".text =
        builtins.readFile .configs/zsh/kubectl.zsh + ./configs/zsh/prompt.zsh;
    };
  };
}
