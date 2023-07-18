_: {
  programs.readline = {
    enable = true;
    bindings = {
      "\\t" = "menu-complete";
      "\\e[Z" = "menu-complete-backward";
      "\\C-w" = "backward-kill-word";
      "\\C-p" = "history-search-backward";
      "\\C-n" = "history-search-forward";
      "\\e[A" = "history-search-backward";
      "\\e[B" = "history-search-forward";
      "\\C-d" = "possible-completions";
      "\\C-l" = "complete";
      "\\C-f" = "complete-filename";
      "\\C-e" = "complete-command";
      "\\C-a" = "insert-completions";
      "\\C-k" = "kill-whole-line";
    };
    variables = {
      "completion-ignore-case" = "on";
      "show-all-if-ambiguous" = "on";
      "colored-stats" = "on";
      "mark-symlinked-directories" = true;
      "show-mode-in-prompt" = true;
      "revert-all-at-newline" = true;
      "completion-display-width" = 4;
      "enable-bracketed-paste" = "on";
    };
  };
}
