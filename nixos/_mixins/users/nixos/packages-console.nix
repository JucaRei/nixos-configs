{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
  ];
  programs.fish.enable = true;
}
