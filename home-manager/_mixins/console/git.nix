{ pkgs, ... }: {
  programs = {
    gh = {
      enable = true;
      extensions = with pkgs; [ gh-markdown-preview ];
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
          features = "side-by-side line-numbers decorations";
          syntax-theme = "Dracula";
          plus-style = ''syntax "#003800"'';
          minus-style = ''syntax "#3f0001"'';
          decorations = {
            commit-decoration-style = "bold yellow box ul";
            file-style = "bold yellow ul";
            file-decoration-style = "none";
            hunk-header-decoration-style = "cyan box ul";
          };
          delta = { navigate = true; };
          line-numbers = {
            line-numbers-left-style = "cyan";
            line-numbers-right-style = "cyan";
            line-numbers-minus-style = 124;
            line-numbers-plus-style = 28;
          };
        };
      };

      aliases = {
        lg =
          "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        branch-default = ''
          !git symbolic-ref --short refs/remotes/origin/HEAD | sed "s|^origin/||"'';
        checkout-default = ''!git checkout "$(git branch-default)"'';
        rebase-default = ''!git rebase "$(git branch-default)"'';
        merge-default = ''!git merge "$(git branch-default)"'';
        branch-cleanup = ''
          !git branch --merged | egrep -v "(^\*|master|main|dev|development)" | xargs git branch -d #'';
        # Restores the commit message from a failed commit for some reason
        fix-commit =
          ''!git commit -F "$(git rev-parse --git-dir)/COMMIT_EDITMSG" --edit'';
        pushf = "push --force-with-lease";
        logs = "log --show-signature";
      };

      extraConfig = {
        push = {
          default = "matching";
          autoSetupRemote = true;
        };
        pull = { rebase = true; };
        rebase = { autoStash = true; };
        branch = { sort = "-committerdate"; };
        color = { ui = true; };
        init = { defaultBranch = "main"; };
        core = {
          editor = "nvim";
          whitespace = "trailing-space,space-before-tab,indent-with-non-tab";
        };
        checkout = { defaultRemote = "origin"; };
        merge = {
          conflictstyle = "diff3";
          tool = "nvim -d";
        };
        github = { user = "Reinaldo"; };
        commit = { verbose = true; };
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
        "*~"
        ".vscode/"
        "npm-debug.log"
        "dumb.rdb"
        "Thumbs.db"
      ];
      includes = [{ path = "~/.config/git/local"; }];
    };
  };
}
