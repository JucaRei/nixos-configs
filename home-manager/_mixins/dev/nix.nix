{pkgs, ...}: {
  home.packages = with pkgs; [
    deadnix
    #libnurl
    #rnix-lsp
    nil
    alejandra
    #nixpkgs-fmt
    jq # It will use some JSON with its lockfile so better be ready to use this.
    nixfmt # Ideally, it would be nicer if the codebase has their preferred formatter but we'll go with the most common formatter(?).
    rnix-hashes # Quick utility for converting hashes.
    rnix-lsp # Make your editing experience nicer with a nice language server.
    nix-tree # Suprisingly nice exploration tool for your packages in the store directory.
    nurl # Nice way to catch up with some things.
  ];
}
