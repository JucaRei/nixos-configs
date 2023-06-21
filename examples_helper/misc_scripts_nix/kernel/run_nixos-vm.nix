#! /nix/store/k32c6vzr9g1nln6v0gypz6ar6lqjb63l-bash-5.2-p15/bin/bash

export PATH=/nix/store/z2k31yvarhcnlc98a76wm07q7a6ryla5-coreutils-9.1/bin${PATH:+:}$PATH

set -e

NIX_DISK_IMAGE=$(readlink -f "${NIX_DISK_IMAGE:-./nixos.qcow2}") || test -z "$NIX_DISK_IMAGE"

if test -n "$NIX_DISK_IMAGE" && ! test -e "$NIX_DISK_IMAGE"; then
    /nix/store/dzp454ag0gi9f76ww9qzwgaxplzybxc1-qemu-host-cpu-only-7.2.0/bin/qemu-img create -f qcow2 "$NIX_DISK_IMAGE" \
      1024M
fi










# Start QEMU.
exec /nix/store/dzp454ag0gi9f76ww9qzwgaxplzybxc1-qemu-host-cpu-only-7.2.0/bin/qemu-kvm -cpu max \
    -name nixos \-device virtio-rng-pci \
         -net nic,netdev=user.0,model=virtio -netdev user,id=user.0,"$QEMU_NET_OPTS" \
         -virtfs local,path=/nix/store,security_model=none,mount_tag=nix-store \
         -drive cache=writeback,file="$NIX_DISK_IMAGE",id=drive1,if=none,index=1,werror=report -device virtio-blk-pci,drive=drive1 \
         -device virtio-keyboard \
    -kernel ${NIXPKGS_QEMU_KERNEL_nixos:-/nix/store/b1gfkmdyazv4r16q76mw4dh6x3rf3011-nixos-system-nixos-23.05.20230321.dirty/kernel} \
    -initrd /nix/store/b1gfkmdyazv4r16q76mw4dh6x3rf3011-nixos-system-nixos-23.05.20230321.dirty/initrd \
    -append "$(cat /nix/store/b1gfkmdyazv4r16q76mw4dh6x3rf3011-nixos-system-nixos-23.05.20230321.dirty/kernel-params) init=/nix/store/b1gfkmdyazv4r16q76mw4dh6x3rf3011-nixos-system-nixos-23.05.20230321.dirty/init regInfo=/nix/store/l46aqrqxsi7dh38c654za9sazk6nq25z-closure-info/registration console=tty0 console=ttyS0,115200n8 $QEMU_KERNEL_PARAMS" \
    -nographic \
    -chardev \
    stdio,id=kgdb \
    -serial \
    unix:${ktest_out}/vm/kgdb,server,nowait \
    -monitor \
    unix:${ktest_out}/vm/mon,server,nowait \
         $QEMU_OPTS \
         "$@"