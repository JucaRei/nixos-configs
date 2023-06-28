{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    neovim
    duf
    neofetch
    ookla-speedtest
    bat
    du-dust
    htop
  ];
}
