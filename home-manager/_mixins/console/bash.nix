{config, ...}: {
  programs.bash = {
    enable = true;
    enableCompletion = true;

    historyControl = ["erasedups" "ignoredups" "ignorespace"];

    #historyFileSize = 10000;
    historyFile = "$HOME/.bash_history";
    historyIgnore = ["ls" "exit" "kill"];

    shellOptions = [
      "histappend" # Append to history file rather than replacing it.
      "autocd"
      "globstar" # Extended globbing.
      "extglob" # Extended globbing.
      "checkwinsize" # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
      "cdspell"
      "dirspell"
      "expand_aliases"
      "dotglob"
      "gnu_errfmt"
      "histreedit"
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

         if [ -n "$VIRTUAL_ENV" ]; then
          env=$(basename "$VIRTUAL_ENV")
          export PS1="($env) $PS1"
        fi


        if [ ! -z "$WSL_DISTRO_NAME" -a -d ~/.nix-profile/etc/profile.d ]; then
          for f in ~/.nix-profile/etc/profile.d/* ; do
            source $f
          done
        fi

        # search Files and Edit
      fe() {
        rg --files ''${1:-.} | fzf --preview 'bat -f {}' | xargs $EDITOR
      }
      # Search content and Edit
      se() {
        fileline=$(rg -n ''${1:-.} | fzf | awk '{print $1}' | sed 's/.$//')
        $EDITOR ''${fileline%%:*} +''${fileline##*:}
      }

      nbfkg() {
      nix build -f . --keep-going $@
      }

      # Search git log, preview shows subject, body, and diff
      fl() {
        git log --oneline --color=always | fzf --ansi --preview="echo {} | cut -d ' ' -f 1 | xargs -I @ sh -c 'git log --pretty=medium -n 1 @; git diff @^ @' | bat --color=always" | cut -d ' ' -f 1 | xargs git log --pretty=short -n 1
      }


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

        [ -f $HOME/.nix-profile/etc/profile.d/nix.sh ] && . $HOME/.nix-profile/etc/profile.d/nix.sh

        # useful for showing icons on non-NixOS systems
        export XDG_DATA_DIRS=$HOME/.nix-profile/share:$XDG_DATA_DIRS

        [ -d "$HOME/.local/bin" ] && export PATH=$PATH:$HOME/.local/bin
        [ -d "$HOME/.poetry/bin" ] && export PATH=$PATH:$HOME/.poetry/bin
        [ -d "$HOME/go/bin" ] && export PATH=$PATH:$HOME/go/bin
        # [ -d "$HOME/.dotnet/tools" ] && export PATH=$PATH:$HOME/.dotnet/tools
    '';

    shellAliases = {
      sudo = "sudo "; # will now check for alias expansion after sudo
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      microcode = "grep . /sys/devices/system/cpu/vulnerabilities/*";
      hw = "hwinfo --short";
      g = "git";
      gco = "git checkout";
      gst = "git status";
      nfl = "nix flake lock";
      nflu = "nix flake lock --update-input";
      vimdiff = "nvim -d";
      vim = "nvim";
      vi = "nvim";
      wget = "wget -c";
      rg = "rg --sort path";
      jctl = "journalctl -p 3 -xb";
      opt = ''
        manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --ansi --preview="manix '{}' | sed 's/type: /> type: /g' | bat -l Markdown --color=always --plain"'';
      to32 = "nix-hash --to-base32 --type sha256";

      #MPV
      yta-best = "yt-dlp --extract-audio --audio-format best --output '%(title)s.%(ext)s' --no-keep-video ";
      yta-flac = "yt-dlp --extract-audio --audio-format flac --output '%(title)s.%(ext)s' --no-keep-video ";
      yta-m4a = "yt-dlp --extract-audio --audio-format m4a --output '%(title)s.%(ext)s' --no-keep-video ";
      yta-mp3 = "yt-dlp --extract-audio --audio-format mp3 --output '%(title)s.%(ext)s' --no-keep-video ";
      yta-opus = "yt-dlp --extract-audio --audio-format opus --output '%(title)s.%(ext)s' --no-keep-video ";
      yta-vorbis = "yt-dlp --extract-audio --audio-format vorbis --output '%(title)s.%(ext)s' --no-keep-video ";
      yta-wav = "yt-dlp --extract-audio --audio-format wav --output '%(title)s.%(ext)s' --no-keep-video ";
      ytv-best = "yt-dlp -f bestvideo+bestaudio --output '%(title)s.%(ext)s' --no-keep-video ";
      ytv-best-mp4 = "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --no-keep-video --embed-chapters --output '%(title)s.%(ext)s' ";
      ytv-best-playlist = "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --no-keep-video --embed-chapters --output '%(playlist_uploader)s/%(playlist_title)s/%(title)s. [%(id)s].%(ext)s' ";
      ytv-best-playlist2 = "yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --no-keep-video --embed-chapters --output '%(playlist_uploader)s/%(playlist_index)s/%(title)s. [%(id)s].%(ext)s' ";
      yt-plMed = "yt-dlp -f 'bestvideo[height<=720][ext=mp4]+bestaudio/best[height<=720][ext=m4a]' --merge-output-format mp4 --no-keep-video --embed-chapters --output '%(title)s.%(ext)s' ";
      yt-plHigh = "yt-dlp -f 'bestvideo[height<=1080][ext=mp4]+bestaudio/best[height<=1080][ext=m4a]' --merge-output-format mp4 --no-keep-video --embed-chapters --output '%(title)s.%(ext)s' ";

      suspend = "systemctl suspend";
    };

    initExtra = ''
      # Ctrl+W kills word
      stty werase undef

      # fzy reverse search
      __fzy_history() {
          ch="$(fc -rl 1 | awk -F'\t' '{print $2}' | sort -u | fzy)"
          : "''${ch#"''${ch%%[![:space:]]*}"}"
          printf "$_"
      }

      bind -x '"\C-r": READLINE_LINE=$(__fzy_history); READLINE_POINT="''${#READLINE_LINE}"'

      #complete -cf doas

      source <(kubectl completion bash)
      complete -F __start_kubectl k
    '';

    #shellOptions = options.programs.bash.shellOptions.default ++ [ "pipefail" ];
  };
}
