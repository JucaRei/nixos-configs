{ pkgs, ... }: {
  local.dock.entries = [
    { path = "${pkgs.emacs}/Applications/Emacs.app/"; }
    { path = "/Applications/Mailplane.app"; }
    { path = "/Applications/IRCCloud.app/"; }
    { path = "/Applications/Google Chrome.app/"; }
    { path = "/Applications/iPulse.app/"; }
    { path = "/Applications/Dash.app/"; }
    { path = "/System/Applications/Messages.app/"; }
    { path = "/Applications/iTerm.app/"; }
    { path = "/System/Applications/Music.app/"; }
    {
      path = "/System/Applications/Home.app/";
    }

    # Folders:
    {
      path = "/Users/asf/Downloads/";
      section = "others";
      options = "--sort dateadded --view grid --display folder";
    }
    {
      path = "/Users/asf/Mess/Mess/";
      section = "others";
      options = "--sort name --view grid --display folder";
    }
  ];
}
