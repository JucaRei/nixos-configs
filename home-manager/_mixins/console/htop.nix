{ config, pkgs, ... }: {
  programs.htop = { enable = true; };
  home = {
    packages = [ pkgs.htop ];
    file = {
      "${config.xdg.configHome}/.config/htop/htoprc".text =
        builtins.readFile ./configs/htop/htoprc;
    };
  };
}
