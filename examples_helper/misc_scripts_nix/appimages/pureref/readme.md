PureRef nixpkg
==============

This is a hacky appimage wrapper nixpkg for PureRef to integrate it into NixOS better. As you may know, it's donationware, so the author encourages a donation and this means there's no way around manually downloading the program. So as a prerequisite, you need to download PureRef separately and slap it in the same folder as the Nix file, or alternatively, change the path to an absolute one, e.g.

    src = /home/you/Downloads/PureRef-1.11.1_x64.Appimage;

Ideally this would use the actual Nixpkg appimage build tooling... but that's effort, and I just want to get shit done right now and this works fine.

### Usage

In your configuration.nix, or home.nix, you use `callPackage` to turn it into a package you can put into `environment.systemPackages` or `home.packages`:

      pureref = pkgs.callPackage (import ./pureref.nix) {};

After that's done you can open the program with `pureref` anywhere; it does not have an application desktop entry and won't show up e.g. in GNOME's application list, I just use Alt+F2 to call `pureref` and it works.
