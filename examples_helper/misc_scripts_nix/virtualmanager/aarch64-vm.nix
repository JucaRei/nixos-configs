{ pkgsPath ? <nixpkgs> }:
let
  pkgs = import pkgsPath { };
  pkgsAarch64 = import pkgsPath { system = "aarch64-linux"; };

  iso =
    (pkgsAarch64.nixos {
      imports = [ (pkgsPath + "/nixos/modules/installer/cd-dvd/installation-cd-base.nix") ];
      users.users.root.openssh.authorizedKeys.keyFiles = [ (builtins.fetchurl "https://github.com/lheckemann.keys") ];
    }).config.system.build.isoImage;

  vmScript = pkgs.writeScript "run-nixos-vm" ''
    #!${pkgs.runtimeShell}
    ${pkgs.qemu}/bin/qemu-system-aarch64 \
      -machine virt,gic-version=max \
      -cpu max \
      -m 2G \
      -smp 4 \
      -drive file=$(echo ${iso}/iso/*.iso),format=raw,readonly=on \
      -nographic \
      -bios ${pkgsAarch64.OVMF.fd}/FV/QEMU_EFI.fd
  '';
in
vmScript
