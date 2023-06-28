{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    neovim
    duf
    neofetch
    speedtest-cli
  ];
}
