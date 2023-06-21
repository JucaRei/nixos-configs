Build a bare bones bootable nixos qcow2 image suitable for running with libvirt/qemu/kvm. 

```
nix-build '<nixpkgs/nixos>' -A config.system.build.qcow2 --arg configuration "{ imports = [ ./build-qcow2.nix ]; }"
```

Should create a `results` directory that symlinks to a qcow2 image in the store.

I basically copied this from the [openstack image in nixpkgs][1] because I don't know a better way.

Update:

Thanks to @d-goldin I've just learnt I can start a VM using just:

```
nix-build '<nixpkgs/nixos>' -A vm -I nixos-config=./machine-config.nix build-vm
./result/bin/run-nixos-vm
```

Which is pretty neat, and I guess pretty common.

[1]: https://github.com/NixOS/nixpkgs/blob/9e8140864bf629ea2d781a863abfedd6cab4229f/nixos/maintainers/scripts/openstack/openstack-image.nix