### nix-configs
let
  # home-manager.nix
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions =
      pkgs.vscode-utils.extensionsFromVscodeMarketplace
      (import (fileFromMisc "vscode/extensions.nix"));
  };

  # configuration.nix
  services.code-server = {
    enable = true;
    auth = "none";
    host = "0.0.0.0";
    user = "kress";
    port = 42069;
  };

  # extensions.nix
  extensions = [
    # adpyke.codesnap-1.3.4
    # gruntfuggly.todo-tree-0.0.220
    # pflannery.vscode-versionlens-1.0.12
    # arrterian.nix-env-selector-1.0.9
    # hbenl.vscode-test-explorer-2.21.1
    # ryu1kn.partial-diff-1.4.3
    # brettm12345.nixfmt-vscode-0.0.1
    # ionide.discoverpanel-0.1.0
    # sleistner.vscode-fileutils-3.5.0
    # chouzz.vscode-better-align-1.3.1
    # ionide.ionide-fsharp-7.4.0
    # tintoy.msbuild-project-tools-0.4.9
    # chunsen.bracket-select-2.0.2
    # ionutvmi.path-autocomplete-1.22.1
    # tomsaunders.vscode-workspace-explorer-1.5.0
    # davidlgoldberg.jumpy2-1.0.1
    # lamartire.git-indicators-2.1.2
    # valentjn.vscode-ltex-13.1.0
    # denoland.vscode-deno-3.16.0
    # mechatroner.rainbow-csv-3.5.0
    # waderyan.gitblame-10.1.0
    # donjayamanne.githistory-0.6.19
    # mhutchie.git-graph-1.30.0
    # yatki.vscode-surround-1.5.0
    # dprint.dprint-0.13.5
    # ms-dotnettools.csharp-1.25.2-linux-x64
    # yzhang.markdown-all-in-one-3.5.0
    # editorconfig.editorconfig-0.16.4
    # ms-vscode.test-adapter-converter-0.1.6
    # elmtooling.elm-ls-vscode-2.6.0
    # paolodellepiane.fantomas-fmt-0.3.0
    {
      name = "codesnap";
      publisher = "adpyke";
      version = "1.3.4";
      sha256 = "dR6qODSTK377OJpmUqG9R85l1sf9fvJJACjrYhSRWgQ=";
    }
    {
      name = "todo-tree";
      publisher = "gruntfuggly";
      version = "0.0.220";
      sha256 = "U7aY2/ESz9f8foBjydy1G/bWd7CLNyIjDWE3pytZfxo=";
    }
    {
      name = "vscode-versionlens";
      publisher = "pflannery";
      version = "1.0.12";
      sha256 = "J78XR6Tmj/Q8wcA2hNIgNAsXQ1ZvXdWm27DiKt4vWac=";
    }
    {
      name = "nix-env-selector";
      publisher = "arrterian";
      version = "1.0.9";
      sha256 = "TkxqWZ8X+PAonzeXQ+sI9WI+XlqUHll7YyM7N9uErk0=";
    }
    {
      name = "vscode-test-explorer";
      publisher = "hbenl";
      version = "2.21.1";
      sha256 = "fHyePd8fYPt7zPHBGiVmd8fRx+IM3/cSBCyiI/C0VAg=";
    }
    {
      name = "partial-diff";
      publisher = "ryu1kn";
      version = "1.4.3";
      sha256 = "0Oiw9f+LLGkUrs2fO8vs7ITSR5TT+5T0yU81ouyedHQ=";
    }
    # {
    #   name = "nixfmt-vscode";
    #   publisher = "brettm12345";
    #   version = "0.0.1";
    #   sha256 = "";
    # }
    # {
    #   name = "discoverpanel";
    #   publisher = "ionide";
    #   version = "0.1.0";
    #   sha256 = "";
    # }
    # {
    #   name = "vscode-fileutils";
    #   publisher = "sleistner";
    #   version = "3.5.0";
    #   sha256 = "";
    # }
    # {
    #   name = "vscode-better-align";
    #   publisher = "chouzz";
    #   version = "1.3.1";
    #   sha256 = "";
    # }
    {
      name = "ionide-fsharp";
      publisher = "ionide";
      version = "7.4.0";
      sha256 = "dKABJ4IT4zXmFWfjePb8SS3EDeLCiDfSaa1tqN8NY+A=";
    }
    # {
    #   name = "msbuild-project-tools";
    #   publisher = "tintoy";
    #   version = "0.4.9";
    #   sha256 = "";
    # }
    # {
    #   name = "bracket-select";
    #   publisher = "chunsen";
    #   version = "2.0.2";
    #   sha256 = "";
    # }
    # {
    #   name = "path-autocomplete";
    #   publisher = "ionutvmi";
    #   version = "1.22.1";
    #   sha256 = "";
    # }
    # {
    #   name = "vscode-workspace-explorer";
    #   publisher = "tomsaunders";
    #   version = "1.5.0";
    #   sha256 = "";
    # }
    # {
    #   name = "jumpy2";
    #   publisher = "davidlgoldberg";
    #   version = "1.0.1";
    #   sha256 = "";
    # }
    # {
    #   name = "git-indicators";
    #   publisher = "lamartire";
    #   version = "2.1.2";
    #   sha256 = "";
    # }
    # {
    #   name = "vscode-ltex";
    #   publisher = "valentjn";
    #   version = "13.1.0";
    #   sha256 = "";
    # }
    # {
    #   name = "vscode-deno";
    #   publisher = "denoland";
    #   version = "3.16.0";
    #   sha256 = "";
    # }
    # {
    #   name = "rainbow-csv";
    #   publisher = "mechatroner";
    #   version = "3.5.0";
    #   sha256 = "";
    # }
    # {
    #   name = "gitblame";
    #   publisher = "waderyan";
    #   version = "10.1.0";
    #   sha256 = "";
    # }
    # {
    #   name = "githistory";
    #   publisher = "donjayamanne";
    #   version = "0.6.19";
    #   sha256 = "";
    # }
    # {
    #   name = "git-graph";
    #   publisher = "mhutchie";
    #   version = "1.30.0";
    #   sha256 = "";
    # }
    # {
    #   name = "vscode-surround";
    #   publisher = "yatki";
    #   version = "1.5.0";
    #   sha256 = "";
    # }
    # {
    #   name = "dprint";
    #   publisher = "dprint";
    #   version = "0.13.5";
    #   sha256 = "";
    # }
    {
      name = "csharp";
      publisher = "ms-dotnettools";
      version = "1.25.2";
      sha256 = "//bM+v7k9UE2NB0IqPszOgK3dEUbPQS9ayLgDnu1BaA=";
    }
    # {
    #   name = "markdown-all-in-one";
    #   publisher = "yzhang";
    #   version = "3.5.0";
    #   sha256 = "";
    # }
    # {
    #   name = "editorconfig";
    #   publisher = "editorconfig";
    #   version = "0.16.4";
    #   sha256 = "";
    # }
    # {
    #   name = "test-adapter-converter";
    #   publisher = "ms-vscode";
    #   version = "0.1.6";
    #   sha256 = "";
    # }
    # {
    #   name = "elm-ls-vscode";
    #   publisher = "elmtooling";
    #   version = "2.6.0";
    #   sha256 = "";
    # }
    # {
    #   name = "fantomas-fmt";
    #   publisher = "paolodellepiane";
    #   version = "0.3.0";
    #   sha256 = "";
    # }
  ];
in {}
