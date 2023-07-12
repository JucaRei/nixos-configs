{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
  home = {
    packages = with pkgs; [ zsh ];
    file = let files = [ ./configs/zsh/kubectl.zsh ./configs/zsh/prompt.zsh ];
    in {
      "${config.xdg.configHome}/.zshrc".text =
        builtins.readFile (builtins.elem files);
    };
  };
}
