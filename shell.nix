# Shell for bootstrapping flake-enabled nix and home-manager
# Enter it through 'nix develop' or (legacy) 'nix-shell'
{pkgs ? (import ./nixpkgs.nix) {}}: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes repl-flake recursive-nix";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
      duf
      alejandra
      htop
      #speedtest-cli
      nil
      #direnv
      #nix-direnv
      neofetch
      #nitch
    ];
    shellHook = ''
      echo "
       ______   _           _
      |  ____| | |         | |
      | |__    | |   __ _  | | __   ___   ___
      |  __|   | |  / _\` | | |/ /  / _ \ / __|
      | |      | | | (_| | |   <  |  __/ \\__ \\
      |_|      |_|  \__,_| |_|\_\  \___| |___/
          "
      PATH=${pkgs.writeShellScriptBin "nix" ''
        ${pkgs.nixFlakes}/bin/nix --experimental-features "nix-command flakes repl-flake recursive-nix" "$@"
      ''}/bin:$PATH
    '';
  };
}
# nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
# flatpak run com.visualstudio.code .

