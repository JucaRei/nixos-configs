Using a nixos qemu machine for fun and profit howto, as well creating iso files.

As pointed out [here](https://gist.github.com/tarnacious/f9674436fff0efeb4bb6585c79a3b9ff) one needs just to:

    # generate a machine
    nix-build '<nixpkgs/nixos>' -A vm --arg configuration "{ imports = [ <nixpkgs/nixos/maintainers/scripts/openstack/openstack-image.nix> ]; }"
    # the qcow2 image generated goes like this, see https://github.com/NixOS/nixpkgs/blob/master/nixos/maintainers/scripts/openstack/openstack-image.nix, is i. e. here then: /nix/store/40iv1f54ky0fxxil5wrzxpck9g121inv-nixos-disk-image/nixos.qcow2
    nix-build '<nixpkgs/nixos>' -A config.system.build.openstackImage --arg configuration "{ imports = [ <nixpkgs/nixos/maintainers/scripts/openstack/openstack-image.nix> ]; }"
    # starting vm, needs a while to boot though
    ./result/bin/run-noname-vm  
    
As well see the pointers given in the files' comments.

Comment:  

In the vm  

    nixos-version

> 19.09pre191265.c4adeddb5f8 (Loris)

    ls -1 /nix/store | sort -R -t - -k 2 | grep -i nixos-system

>...
v3861maxbs0yzvaiw5nqh4x21ch23i2h-nixos-system-nixos-19.09pre191265.c4adeddb5f8

    ls /nix/store/v3861maxbs0yzvaiw5nqh4x21ch23i2h-nixos-system-nixos-19.09pre191265.c4adeddb5f8/init

Guess that is the init param for grub then

The usbstick-generation is even simplified as the isos generated seem to be hybrid, meaning one can burn them 1:1 to usbsticks, https://nixos.org/nixos/manual/index.html#sec-booting-from-usb

Sources:  
https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/qemu-vm.nix (see `options = {` for tunings, i. e. the disk size, `virtualisation.diskSize = 1024 * 2048;` in machine-config.nix)  
https://github.com/teto/nixpkgs/blob/33b0ad83e976ed6bb22b6862ca0637dd2fb765f7/nixos/modules/virtualisation/qemu-vm.nix#L100 (further options, such as setting ssh or adding devices can be tuned by injecting QEMU_OPTS as in `QEMU_NET_OPTS=hostfwd=tcp::2221-:22 QEMU_OPTS="-cdrom /nix/store/435n08rj0w488342jfccigyjnvlfnwmc-nixos.iso/iso/nixos.iso -drive file=/tmp/bootima.img,if=none,id=newstick,format=raw -drive file=/mnt/c/temp/kubrick-usb-base.img,if=none,id=bootstick,format=raw -device nec-usb-xhci,id=xhci -device usb-storage,bus=xhci.0,drive=bootstick,port=1 -device usb-storage,bus=xhci.0,drive=newstick,port=2" ./result/bin/run-nixos-vm &` followed by `ssh -o "StrictHostKeyChecking=no" -i ~/.ssh/id_rsa_github root@localhost -p 2221` assumed machine-config.nix has `openssh` keys as in attached file)  

https://nixos.mayflower.consulting/blog/2018/09/11/custom-images/

https://github.com/rycee/home-manager/issues/1154#issuecomment-616219944  