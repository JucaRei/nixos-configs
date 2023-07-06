#!/bin/sh
export FULL="/dev/vda"
export DRIVE="vda"
sgdisk -Z $FULL
sgdisk -n 0:0:200MiB /dev/vda
sgdisk -n 0:0:0 /dev/vda

export BOOT_PARTITION="${DRIVE}1"
export ROOT_PARTITION="${DRIVE}2"

umount -R /mnt
sgdisk -t 1:ef00 /dev/$DRIVE
sgdisk -t 2:8300 /dev/$DRIVE
sgdisk -c 1:EFI /dev/$DRIVE
sgdisk -c 2:NIXOS /dev/$DRIVE
parted /dev/$BOOT_PARTITION -- set 1 esp on
sgdisk -p /dev/$DRIVE

mkfs.vfat -F32 /dev/$BOOT_PARTITION -n "EFI"
mkfs.btrfs /dev/$ROOT_PARTITION -f -L "NIXOS"

BTRFS_OPTS="rw,noatime,ssd,compress-force=zstd:15,space_cache=v2,nodatacow,commit=120,autodefrag,discard=async"
SWAPFILE_OPTS="defaults,noatime"
mount -o $BTRFS_OPTS /dev/$ROOT_PARTITION /mnt
btrfs su cr /mnt/@root
btrfs su cr /mnt/@home
btrfs su cr /mnt/@nix
btrfs su cr /mnt/@snapshots
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@swap
umount -R /mnt

# mount -o $BTRFS_OPTS,subvol=@root /dev/vda2 /mnt
mount -o $BTRFS_OPTS,subvol="@root" /dev/disk/by-label/NIXOS /mnt
# mount -o $BTRFS_OPTS,subvol="@root" /dev/disk/by-partlabel/NIXOS /mnt
mkdir -pv /mnt/{boot/efi,home,.snapshots,var/tmp,nix,swap}
mount -o $BTRFS_OPTS,subvol="@home" /dev/disk/by-label/NIXOS /mnt/home
# mount -o $BTRFS_OPTS,subvol="@home" /dev/disk/by-partlabel/NIXOS /mnt/home
mount -o $BTRFS_OPTS,subvol="@snapshots" /dev/disk/by-label/NIXOS /mnt/.snapshots
# mount -o $BTRFS_OPTS,subvol="@snapshots" /dev/disk/by-partlabel/NIXOS /mnt/.snapshots
mount -o $BTRFS_OPTS,subvol="@tmp" /dev/disk/by-label/NIXOS /mnt/var/tmp
# mount -o $BTRFS_OPTS,subvol="@tmp" /dev/disk/by-partlabel/NIXOS /mnt/var/tmp
mount -o $BTRFS_OPTS,subvol="@nix" /dev/disk/by-label/NIXOS /mnt/nix
# mount -o $BTRFS_OPTS,subvol="@nix" /dev/disk/by-partlabel/NIXOS /mnt/nix
mount -o $SWAPFILE_OPTS,subvol="@swap" /dev/disk/by-label/NIXOS /mnt/swap
truncate -s 0 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
btrfs property set /mnt/swap/swapfile compression none
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=2048
chmod 0600 /mnt/swap/swapfile
mkswap /mnt/swap/swapfile
swapon /mnt/swap/swapfile

mount -t vfat -o rw,defaults,noatime,nodiratime /dev/disk/by-label/EFI /mnt/boot/efi

# for dir in dev proc sys run; do
#    mount --rbind /$dir /mnt/$dir
#    mount --make-rslave /mnt/$dir
# done

# UEFI_UUID=$(blkid -s UUID -o value /dev/vda1)
# ROOT_UUID=$(blkid -s UUID -o value /dev/vda2)

# mkdir -pv /home/nixos/.config/nix/
# touch /home/nixos/.config/nix/nix.conf
# echo "experimental-features = nix-command flakes" >> /home/nixos/.config/nix/nix.conf

# nixos-generate-config --root /mnt
# nix.settings.experimental-features = [ "nix-command" "flakes" ];

# nix-env -iA nixos.git

# git clone --depth=1 https://github.com/JucaRei/teste-repo /home/nixos/.setup
# git clone --depth=1 https://github.com/JucaRei/nixos-conf /home/nixos/.setup

## Install flake repo
# sudo nixos-install -v --root /mnt --impure --flake /home/nixos/.setup#vm
# sudo nixos-install -v --root /mnt --impure --flake github:JucaRei/nixos-conf#vm
# sudo nixos-install -v --root /mnt --impure --flake .#mcbair
# sudo nixos-rebuild --flake /home/nixos/.setup#vm
# sudo nixos-rebuild switch --flake /home/nixos/.setup#vm
# sudo nixos-rebuild switch --flake /home/nixos/.setup#vm --fallback

## Chroot

# nixos-enter --root /mnt                             # Start an interactive shell in the NixOS installation in /mnt
# nixos-enter -c 'ls -l /; cat /proc/mounts'          # Run a shell command
# nixos-enter -- cat /proc/mounts                     # Run a non-shell command

# nix flake check --no-build github:NixOS/patchelf

## Check dots
# nix flake check --no-build github:JucaRei/nixos-conf#vm --extra-experimental-features nix-command --extra-experimental-features flakes
# nix flake check --no-build --no-write-lock-file github:JucaRei/nixos-conf --extra-experimental-features nix-command --extra-experimental-features flakes
# nix flake check --no-build --no-write-lock-file --show-trace github:JucaRei/nixos-conf --extra-experimental-features nix-command --extra-experimental-features flakes
