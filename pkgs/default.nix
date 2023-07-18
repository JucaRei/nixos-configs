# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{pkgs ? (import ../nixpkgs.nix) {}}: {
  # example = pkgs.callPackage ./example { };
  nvchad = pkgs.callPackage ./nvchad {};
  firefox-csshacks = pkgs.callPackage ./firefox-csshacks {};
  #tidal-dl = pkgs.python3Packages.callPackage ./tidal-dl { };
}
