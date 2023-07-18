{ variables, pkgs, }: [{
  target = "${variables.homeDir}/.bashrc";
  source = pkgs.writeScript "bashrc" ''
    eval "$(${pkgs.starship}/bin/starship init bash)"
  '';
}]
