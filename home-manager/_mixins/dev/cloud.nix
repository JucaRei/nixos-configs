{ pkgs, ... }: {
  home.packages = with pkgs; [
    terraform
    #docker-compose
  ];
}
