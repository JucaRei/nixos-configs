{pkgs, ...}: {
  home.packages = with pkgs; [
    deadnix
    #nixpkgs-fmt
    #libnurl
    #rnix-lsp
    nil
    alejandra
  ];
}
