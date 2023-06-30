{pkgs, ...}: {
  programs = {
    gh = {
      enable = true;
      extensions = with pkgs; [
        gh-markdown-preview
      ];
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };

    git = {
      enable = true;
      delta = {
        enable = true;
        options = {
          features = "decorations";
          navigate = true;
          side-by-side = true;
        };
      };

      aliases = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };

      extraConfig = {
        push = {
          default = "matching";
        };
        pull = {
          rebase = true;
        };
        init = {
          defaultBranch = "main";
        };
        core = {
          editor = "nvim";
          whitespace = "trailing-space,space-before-tab";
        };
        merge = {
          conflictstyle = "diff3";
        };
        commit = {
          verbose = true;
        };
        url = {
          "https://github.com/".insteadOf = "gh:";
          "git@github.com:".pushInsteadOf = "gh:";
          "https://gitlab.com/".insteadOf = "gl:";
          "git@gitlab.com:".pushInsteadOf = "gl:";
        };
      };

      ignores = [
        "*.log"
        "*.out"
        ".DS_Store"
        "bin/"
        "dist/"
        "result"
        ".cache/"
        ".DS_Store"
        ".direnv/"
        "*.swp"
        ".vscode/"
        "npm-debug.log"
        "dumb.rdb"
      ];
    };
  };
}
