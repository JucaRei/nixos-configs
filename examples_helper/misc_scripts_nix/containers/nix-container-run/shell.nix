with import <nixpkgs> {}; {
  user-mounts = callPackage ./user-mounts.nix {};
}
