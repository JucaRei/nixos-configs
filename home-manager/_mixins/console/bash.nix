{ options, config, pkgs, ... }:

{
  programs.bash = {
    enable = true;

    historyControl = [ "erasedups" "ignorespace" "checkwinsize" ];

    historyFileSize = 1000;

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
            
            if [ -n "$force_color_prompt" ]; then
              if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
                # We have color support; assume it's compliant with Ecma-48
                # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
                # a case would tend to support setf rather than setaf.)
                color_prompt=yes
              else
                color_prompt=
              fi
            fi
            
            if [ "$color_prompt" = yes ]; then
              PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
            else
              PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
            fi
            unset color_prompt force_color_prompt

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

    shellOptions = options.programs.bash.shellOptions.default ++ [ "pipefail" ];
  };
}
