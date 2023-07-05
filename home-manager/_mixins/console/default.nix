{ pkgs, ... }: {
  imports = [
    ./fish.nix
    ./bat.nix
    ./bash.nix
    ./git.nix
    ./neofetch.nix
    ./broot.nix
    ./xdg.nix
  ];

  home = {
    # A Modern Unix experience
    # https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
    packages = with pkgs; [
      #asciinema                     # Terminal recorder
      #black                         # Code format Python
      #bmon                          # Modern Unix `iftop`
      #breezy                        # Terminal bzr client
      #butler                        # Terminal Itch.io API client
      #chafa                         # Terminal image viewer
      #chroma                        # Code syntax highlighter
      #clinfo                        # Terminal OpenCL info
      #croc                          # Terminal file transfer
      #curlie                        # Terminal HTTP client
      #debootstrap                   # Terminal Debian installer
      diffr # Modern Unix `diff`
      #difftastic                    # Modern Unix `diff`
      #dogdns                        # Modern Unix `dig`
      dua # Modern Unix `du`
      duf # Modern Unix `df`
      #du-dust                       # Modern Unix `du`
      #entr                          # Modern Unix `watch`
      fd # Modern Unix `find`
      ffmpeg-headless # Terminal video encoder
      #glow                          # Terminal Markdown renderer
      #gping                         # Modern Unix `ping`
      #hexyl                         # Modern Unix `hexedit`
      #httpie                        # Terminal HTTP client
      #hueadm                        # Terminal Philips Hue client
      #hugo                          # Terminal static site generator
      #hyperfine                     # Terminal benchmarking
      #iperf3                        # Terminal network benchmarking
      #jpegoptim                     # Terminal JPEG optimizer
      jiq # Modern Unix `jq`
      #lazygit                       # Terminal Git client
      #libva-utils                   # Terminal VAAPI info
      #lurk                         # Modern Unix `strace`
      #maestral                      # Terminal Dropbox client
      #mdp                           # Terminal Markdown presenter
      #mktorrent                     # Terminal torrent creator
      moar # Modern Unix `less`
      #mtr                           # Modern Unix `traceroute`
      #netdiscover                   # Modern Unix `arp`
      #nethogs                       # Modern Unix `iftop`
      #nodePackages.prettier         # Code format
      #nyancat                       # Terminal rainbow spewing feline
      ookla-speedtest # Terminal speedtest
      #optipng                       # Terminal PNG optimizer
      #playerctl                     # Terminal media controller
      #procs                         # Modern Unix `ps`
      #pulsemixer                    # Terminal PulseAudio mixer
      #python310Packages.gpustat     # Terminal GPU info
      #quilt                         # Terminal patch manager
      #rclone                        # Terminal cloud storage client
      ripgrep # Modern Unix `grep`
      #rustfmt                       # Code format Rust
      #s3cmd                         # Terminal cloud storage client
      #shellcheck                    # Code lint Shell
      #shfmt                         # Code format Shell
      tldr # Modern Unix `man`
      #tokei                         # Modern Unix `wc` for code
      #vdpauinfo                     # Terminal VDPAU info
      #wavemon                       # Terminal WiFi monitor
      #wmctrl                        # Terminal X11 automation
      #xdotool                       # Terminal X11 automation
      #yadm                          # Terminal dot file manager
      #ydotool                       # Terminal *all-the-things* automation
      #yq-go                         # Terminal `jq` for YAML
      #zsync                         # Terminal file sync

      ### Ansible
      ansible # Automation
      sshpass # Ansible Dependency

      ### Archive Tools
      unzip
      unrar
      zip
      p7zip
      xar

      ### Nix
      alejandra # Code format Nix
      nurl # Nix URL fetcher
      nix-index # nix-locate
      rnix-hashes # Quick utility for converting hashes.
      nix-top # see what's building
      nixpkgs-fmt # Code format Nix
      nixpkgs-review # Nix code review
      dconf2nix # Nix code from Dconf files
      deadnix # Code lint Nix
    ];

    sessionVariables = {
      EDITOR = "micro";
      MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
      PAGER = "moar";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
      #EDITOR = "nvim";
      #SYSTEMD_EDITOR = "nvim";
      #VISUAL = "nvim";
    };
  };

  programs = {
    atuin = {
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
    skim = rec {
      enable = true;
      defaultCommand = "fd --type f --hidden --exclude '.git'";
      defaultOptions = [ "--height 40%" "--inline-info" ];
      changeDirWidgetCommand = "fd --type d --hidden --exclude '.git'";
      fileWidgetCommand = defaultCommand;
      fileWidgetOptions = [
        "--preview 'bat --color always {} 2> /dev/null | head -200; highlight -O ansi -l {} ^ /dev/null | head -200 || cat {} ^ /dev/null | head -200'"
      ];
      historyWidgetOptions = [ "--tac" ];
    };
    bottom = {
      enable = true;
      settings = {
        colors = {
          high_battery_color = "green";
          medium_battery_color = "yellow";
          low_battery_color = "red";
        };
        disk_filter = {
          is_list_ignored = true;
          list = [ "/dev/loop" ];
          regex = true;
          case_sensitive = false;
          whole_word = false;
        };
        flags = {
          dot_marker = false;
          enable_gpu_memory = true;
          group_processes = true;
          hide_table_gap = true;
          mem_as_value = true;
          tree = true;
        };
      };
    };
    command-not-found.enable = true;
    dircolors = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv = { enable = true; };
    };
    exa = {
      enable = true;
      enableAliases = true;
      icons = true;
    };
    gpg.enable = true;
    home-manager.enable = true;
    info.enable = true;
    jq.enable = true;
    micro = {
      enable = true;
      #enable = true;
      settings = {
        #colorcolumn = 80;
        colorscheme = "simple";
        diffgutter = true;
        rmtrailingws = true;
        savecursor = true;
        saveundo = true;
        scrollbar = true;
      };
    };
    powerline-go = {
      enable = true;
      settings = {
        cwd-max-depth = 5;
        cwd-max-dir-size = 12;
        max-width = 60;
      };
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      #enable = false;
      enableSshSupport = true;
      pinentryFlavor = "curses";
    };
    kbfs = {
      enable = true;
      #enable = false;
      mountPoint = "Keybase";
    };
    keybase.enable = true;
    #keybase.enable = false;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
