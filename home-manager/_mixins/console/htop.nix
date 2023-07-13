{
  config,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      htop
    ];
    file = {
      "${config.xdg.configHome}/.configs/htop/htoprc".text = builtins.readFile ./configs/htop/htoprc;
    };
  };
}
