{ desktop, lib, ... }: {
  imports = [
    ./podman.nix
    ./distrobox.nix
    # ./docker.nix
  ] ++ lib.optional (builtins.isString desktop) ./quickemu.nix
    ++ lib.optional (builtins.isString desktop) ./virt-manager.nix;
}
