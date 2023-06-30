{ inputs, outputs, stateVersion, ... }: {
  # Helper function for generating home-manager configs
  mkHome = { hostname, username, desktop ? null, hostPlatform ? "x86_64-linux" ? "aarch64-linux" }: inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${hostPlatform};
    extraSpecialArgs = {
      inherit inputs outputs desktop hostname hostPlatform username stateVersion;
    };
    modules = [ ../home-manager ];
  };

  # Helper function for generating host configs
  mkHost =
    { hostname, username, desktop ? null, hostid ? null, installer ? null }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs desktop hostname username hostid stateVersion;
      };
      modules = [ ../nixos ]
        ++ (if installer != null then [ (installer) ] else [ ]);
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
