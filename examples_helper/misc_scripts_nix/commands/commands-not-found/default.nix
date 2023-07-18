{pkgs, ...}: let
  # Automatically download the latest index from Mic92's nix-index-database.
  nix-locate = pkgs.writeShellScriptBin "nix-locate" ''
    set -euo pipefail
    mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
    # Check for updates at most once a day
    if [ ! -f last-check ] || [ $(find last-check -mtime +1) ]; then
      filename="index-x86_64-$(uname | tr A-Z a-z)"
      # Prevent partial downloads
      [ -f files ] || rm -f $filename
      rm -f files
      wget -q -N --show-progress \
        https://github.com/Mic92/nix-index-database/releases/latest/download/$filename
      ln -sf $filename files
      touch last-check
    fi
    exec ${pkgs.nix-index}/bin/nix-locate "$@"
  '';

  # Modified version of command-not-found.sh that uses our wrapped version of
  # nix-locate, makes the output a bit less noisy, and adds color!
  command-not-found = pkgs.runCommandLocal "command-not-found.sh" {} ''
    mkdir -p $out/etc/profile.d
    substitute ${./command-not-found.sh}                  \
      $out/etc/profile.d/command-not-found.sh             \
      --replace @nix-locate@ ${nix-locate}/bin/nix-locate \
      --replace @tput@ ${pkgs.ncurses}/bin/tput
  '';
in {
  programs.nix-index = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "nix-index";
      # Don't provide 'bin/nix-index', since the index is updated automatically
      # and it is easy to forget that. It can always be run manually with
      # 'nix run nixpkgs#nix-index' if necessary.
      paths = [nix-locate command-not-found];
    };
  };
}
#########################################
## Add
#{ config, pkgs, ... }:
#
#let
#  nixLocateAuto = builtins.fetchTarball {
#    url = "https://gist.github.com/InternetUnexplorer/58e979642102d66f57188764bbf11701/archive/3046ee564fed5b60cee5e5ef39b1837c04cc3aa2.tar.gz";
#    sha256 = "0hz4rpd0g1096sj1bl69kywv1gg14qaq1pk03jifvq9yhcq2i8pc";
#  };
#in {
#  imports = [ "${nixLocateAuto}/default.nix" ];
#  # ...
#}

