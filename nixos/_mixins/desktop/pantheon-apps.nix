{pkgs, ...}: {
  imports = [../services/flatpak.nix];

  environment = {
    # Add some elementary additional apps and include Yaru for syntax highlighting
    systemPackages = with pkgs; [
      #inputs.nix-software-center.packages.${system}.nix-software-center
      appeditor # elementary OS menu editor
      celluloid # Video Player
      formatter # elementary OS filesystem formatter
      gthumb # Image Viewer
      gnome.simple-scan
      #indicator-application-gtk3     # App Indicator
      #pantheon.sideload              # elementary OS Flatpak installer
      yaru-theme
      #cipher                         # elementary OS text encoding/decoding
      #elementary-planner             # UNSTABLE: elementary OS planner with Todoist support
      #evolutionWithPlugins           # Email client
      #minder                         # elementary OS mind-mapping
      #monitor                        # elementary OS system monitor
      #nasc                           # UNSTABLE: elementary OS maths notebook
      #notes-up                       # elementary OS Markdown editor
      #tootle                         # elementary OS Mastodon client
      #torrential                     # elementary OS torrent client
    ];
  };

  # Add GNOME Disks and Pantheon Tweaks
  programs = {
    gnome-disks.enable = true;
    pantheon-tweaks.enable = true;
    seahorse.enable = true;
  };
}
