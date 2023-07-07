{ options, config, pkgs, ... }:

{
  programs.bash = {
    enable = true;

    historyControl = [ "erasedups" "ignorespace" ];

    #historyFileSize = 10000;
    historyFile = "\$HOME/.bash_history";
    historyIgnore = [ "ls" "exit" "kill" ];

    shellOptions = [
      "histappend"
      "autocd"
      "globstar"
      "checkwinsize"
      "cdspell"
      "expand_aliases"
      "dotglob"
      "gnu_errfmt"
      "nocasematch"
    ];

    profileExtra = ''
            # if running bash
            if [ -n "$BASH_VERSION" ]; then
              # include .bashrc if it exists
              if [ -f "$HOME/.bashrc" ]; then
                . "$HOME/.bashrc"
              fi
            fi

            # set PATH so it includes user's private bin if it exists
            if [ -d "$HOME/bin" ] ; then
              PATH="$HOME/bin:$PATH"
            fi

            # set PATH so it includes user's private bin if it exists
            if [ -d "$HOME/.local/bin" ] ; then
              PATH="$HOME/.local/bin:$PATH"
            fi

            if [ -e ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh ]; then
              source ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh
            fi

            if [ -f ~/.bash_aliases ]; then
              . ~/.bash_aliases
            fi

            if ! shopt -oq posix; then
              if [ -f /usr/share/bash-completion/bash_completion ]; then
                . /usr/share/bash-completion/bash_completion
              elif [ -f /etc/bash_completion ]; then
                . /etc/bash_completion
              fi
            fi
    '';

    #shellOptions = options.programs.bash.shellOptions.default ++ [ "pipefail" ];
  };
}
