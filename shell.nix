# Shell for bootstrapping flake-enabled nix and home-manager
# Enter it through 'nix develop' or (legacy) 'nix-shell'
{ pkgs ? (import ./nixpkgs.nix) {
    #system = builtins.forAllSystems;
    #overlays = []; # Explicit blank overlay to avoid interference
  }
,
}: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes repl-flake";
    nativeBuildInputs = with pkgs; [
      home-manager
      git
      duf
      htop
      tree
      jq
      nix
      nil
      #rnix-lsp
      nixpkgs-fmt
      nixfmt
      #alejandra
      nix-direnv
      #direnv
      neofetch
      #nitch
    ];
    shellHook = ''
      export PS1="[\e[0;34m(Flakes)\$\e[m:\w]\$ "
      echo "
       ______   _           _
      |  ____| | |         | |
      | |__    | |   __ _  | | __   ___   ___
      |  __|   | |  / _\` | | |/ /  / _ \ / __|
      | |      | | | (_| | |   <  |  __/ \\__ \\
      |_|      |_|  \__,_| |_|\_\  \___| |___/
          "
      PATH=${
        pkgs.writeShellScriptBin "nix" ''
          ${pkgs.nixFlakes}/bin/nix --experimental-features "nix-command flakes repl-flake" "$@"
        ''
      }/bin:$PATH
    '';
  };
}
# nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
# flatpak run com.visualstudio.code .

