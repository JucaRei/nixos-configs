{
  config,
  pkgs,
  ...
}: let
  files = [./kubectl.zsh ./prompt.zsh ./git.zsh];
  src = builtins.filterSource (p: _t: builtins.elem (./. + p) files) /.;
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
  home = {
    packages = with pkgs; [zsh];
    file = {"${config.xdg.configHome}/.zshrc".text = builtins.readFile src;};
  };
}
