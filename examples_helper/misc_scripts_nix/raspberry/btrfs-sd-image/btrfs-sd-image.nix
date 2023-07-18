{ pkgsPath ? <nixpkgs>, pkgs ? import pkgsPath { system = "aarch64-linux"; }, }:
let
  thirtythree = import (pkgs.path + "/nixos") {
    configuration = {
      nixpkgs.system = "aarch64-linux";
      imports = [ ./configuration.nix ./firmware.nix ];
      boot.loader.grub.enable = false;
      boot.loader.generic-extlinux-compatible.enable = true;
    };
  };

  inherit (thirtythree.config.system.build) toplevel;
  closure = pkgs.closureInfo { rootPaths = [ toplevel ]; };
  inherit (thirtythree.config.system.build) uboot;
in
pkgs.vmTools.runInLinuxVM (pkgs.runCommand "thirtythree-sd"
{
  nativeBuildInputs = with pkgs; [
    btrfs-progs
    util-linux
    gptfdisk
    nix
    strace
    e2fsprogs
  ];
  preVM = ''
    mkdir -p $out
    ${pkgs.vmTools.qemu}/bin/qemu-img create -f qcow2 $out/thirtythree.qcow2 4G
    ${pkgs.gnutar}/bin/tar --owner=0:0 -cf xchg/closure.tar $(< ${closure}/store-paths)
  '';
  memSize = "4G";
  QEMU_OPTS = "-drive file=$out/thirtythree.qcow2,if=virtio -smp 4";
  passthru.uboot = uboot;
} ''
  set -x
  ${pkgs.kmod}/bin/modprobe btrfs
  ${pkgs.udev}/lib/systemd/systemd-udevd &
  sgdisk /dev/vda -Z -o -a1 \
    -n1:10M:0 -t1:8300 -c1:thirtythree
  dd if=${uboot}/u-boot-rockchip.bin of=/dev/vda seek=$((64*512)) oflag=seek_bytes bs=4M

  mkdir -p /mnt /btrfs

  mkfs.btrfs -L thirtythree /dev/vda1
  ${pkgs.udev}/bin/udevadm settle
  mount -t btrfs /dev/vda1 /btrfs

  btrfs subvolume create /btrfs/nix
  btrfs subvolume create /btrfs/root
  btrfs subvolume create /btrfs/boot
  btrfs subvolume create /btrfs/kodi
  btrfs subvolume create /btrfs/persist

  mkdir -p /mnt/var/lib

  mount -v -T "${toplevel}/etc/fstab" --target-prefix /mnt -o X-mount.mkdir /
  mount -v -T "${toplevel}/etc/fstab" --target-prefix /mnt -o X-mount.mkdir --all

  mkdir -p /mnt/nix/store
  ls -lh /tmp/xchg/closure.tar
  tar -C /mnt --no-same-permissions -xf /tmp/xchg/closure.tar
  chown -R 0:0 /mnt/nix
  nix-store --store /mnt --load-db <${closure}/registration

  mkdir /mnt/proc
  mount -t proc proc /mnt/proc
  mkdir /mnt/sys
  mount -t sysfs sys /mnt/sys
  mkdir /mnt/dev
  mount --bind /dev /mnt/dev

  mkdir -p /mnt/nix/var/nix/profiles /mnt/etc /mnt/boot /mnt/persist/{tinc,ssh}
  chown 4000 /mnt/var/lib/kodi
  touch /mnt/etc/NIXOS
  ln -s ${toplevel} /mnt/nix/var/nix/profiles/system
  chroot /mnt ${toplevel}/bin/switch-to-configuration boot --install-bootloader
  umount -R /mnt
'')
