{pkgs, ...}: {
  programs = {
    gh = {
      enable = true;
      extensions = with pkgs; [gh-markdown-preview];
      settings = {
        editor = "micro";
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };

    git = {
      enable = true;

      userName = "Reinaldo P Jr";
      userEmail = "reinaldo800@gmail.com";
      package = pkgs.gitFull.override {
        # Use SSH from macOS instead with support for Keyring
        # https://github.com/NixOS/nixpkgs/issues/62353
        withSsh = !pkgs.stdenv.isDarwin;
      };

      delta = {
        enable = true;
        options = {
          features = "side-by-side line-numbers decorations";
          navigate = true;
          syntax-theme = "Dracula";
          plus-style = ''syntax "#003800"'';
          minus-style = ''syntax "#3f0001"'';
          decorations = {
            commit-decoration-style = "bold yellow box ul";
            file-style = "bold yellow ul";
            file-decoration-style = "none";
            hunk-header-decoration-style = "cyan box ul";
          };
          delta = {navigate = true;};
          line-numbers = {
            line-numbers-left-style = "cyan";
            line-numbers-right-style = "cyan";
            line-numbers-minus-style = 124;
            line-numbers-plus-style = 28;
          };
        };
      };

      aliases = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        branch-default = ''
          !git symbolic-ref --short refs/remotes/origin/HEAD | sed "s|^origin/||"
        '';
        checkout-default = ''!git checkout "$(git branch-default)"'';
        rebase-default = ''!git rebase "$(git branch-default)"'';
        merge-default = ''!git merge "$(git branch-default)"'';
        branch-cleanup = ''
          !git branch --merged | egrep -v "(^\*|master|main|dev|development)" | xargs git branch -d #
        '';
        # Restores the commit message from a failed commit for some reason
        fix-commit = ''
          !git commit -F "$(git rev-parse --git-dir)/COMMIT_EDITMSG" --edit
        '';
        pushf = "push --force-with-lease";
        logs = "log --show-signature";
        # Show the diff between the latest commit and the current state.
        d = "!git diff-index --quiet HEAD -- || clear; git diff --patch-with-stat";
        # `git di $number` shows the diff between the state `$number` revisions ago and the current state.
        di = "!d() { git diff --patch-with-stat HEAD~$1; }; git diff-index --quiet HEAD -- || clear; d";
        # Pull in remote changes for the current repository and all its submodules.
        p = "pull --recurse-submodules";
        # Clone a repository including all submodules.
        c = "clone --recursive";
        # Fetch remote.
        f = "fetch --prune";

        # Show verbose output about tags, branches or remotes.
        tags = "tag -l";
        branches = "branch --all";
        remotes = "remote --verbose";

        # List aliases.
        aliases = "config --get-regexp alias";

        # Commit.
        co = "commit";
        com = "commit -m";
        coa = "!git add -A && git commit -av";

        # Amend commit.
        amend = "commit --amend --reuse-message=HEAD";
        ca = "commit --amend";
        can = "commit --amend --no-edit";
        car = "commit --amend --reset-author";
        carn = "commit --amend --reset-author --no-edit";

        # Credit an author on the latest commit.
        credit = ''!f() { git commit --amend --author "$1 <$2>" -C HEAD; }; f'';

        reb = "rebase -i origin/HEAD --autosquash";
        # Interactive rebase with the given number of latest commits.
        rebn = "!r() { git rebase -i HEAD~$1 --autosquash; }; r";

        # Remove the old tag with this name and tag the latest commit with it.
        retag = "!r() { git tag -d $1 && git push origin :refs/tags/$1 && git tag $1; }; r";

        # List contributors with number of commits.
        contributors = "shortlog --summary --numbered";

        # Show the user email for the current repository.
        whoami = "config user.email";
      };

      extraConfig = {
        push = {
          default = "matching";
          autoSetupRemote = true;
        };
        pull = {rebase = true;};
        rebase = {autoStash = true;};
        branch = {sort = "-committerdate";};
        color = {ui = true;};
        init = {defaultBranch = "main";};
        core = {
          editor = "nvim";
          whitespace = "trailing-space,space-before-tab,indent-with-non-tab";
        };
        checkout = {defaultRemote = "origin";};
        merge = {
          conflictstyle = "diff3";
          tool = "nvim -d";
        };
        github = {user = "Reinaldo";};
        commit = {verbose = true;};
        url = {
          "https://github.com/".insteadOf = "gh:";
          "https://gitlab.com/".insteadOf = "gl:";
          "https://gist.github.com/".insteadOf = "gist:";
          "git@gist.github.com".pushInsteadOf = "gist:";
          "git@gitlab.com:".pushInsteadOf = "gl:";
          "git@github.com:".pushInsteadOf = "gh:";
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
      includes = [{path = "~/.config/git/local";}];
    };
  };
}
