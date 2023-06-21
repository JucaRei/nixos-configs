# VFIO Setup on NixOS

**Disclaimer**: Nobody else tested my setup so far, so this is a "works on my machine" scenario. 
I am not responsible for anything you break on your machine (although I'd not expect much harm).

## Hardware

My system has the following hardware:

 - Board: ASRock X570 Pro4
 - Processor: AMD Ryzen 7 3700x
 - GPU (Primary): Palit GeForce GTX1080 Dual OC (at `0000:01:00.*`, IDs are `10de:1b80` and `10de:10f0`)
 - GPU (Secondary): AMD Radeon Pro WX3100 (at `0000:02:00.*`, IDs are not relevant)

## Files

 - `usage.nix` contains the relevant snippet of my configuration where I use preexisting modules and my custom ones.
 - `win_vm.xml` contains the `libvirtd` xml dump of my Windows 10 guest
   - It is customized to my setup, I only use this one for gaming
 - `virtualisation.nix` is a module to augment the `virtualisations` subtree by the ability to create shared memory files. This is required for `looking-glass` and `pulseaudio-scream` (or `pulseaudio-ivshmem`)
   - Audio integration is not tested by me. Last time I checked, neither `pa-scream` nor `pa-ivshmem` were available and it did not annoy me enough to play around with it
 - `vfio.nix` contains the biggest part of the config. It allows setting a few properties like:
   - `IOMMUType`, either `intel` or `amd`, sets the apropriate kernel parameters for IOMMU
   - `devices`, which is a list of PCI IDs that shall be bound to `vfio-pci`
   - `disableEFIfb` disables the EFI framebuffer. I pass through my primary GPU, so I need to prevent the kernel from touching it
   - `blacklistNvidia` additionally blacklists `nvidia` and `nouveau` kernel modules
   - `ignoreMSRs` toggles `kvm.ignore_msrs` as a kernel parameter
   - `applyACSpatch` applies the well known ACS patch to weaken the IOMMU grouping. **IMPORTANT**: This results in a kernel compilation in most cases.
 - `libvirt.nix` adds two`virtualisation.libvirtd` options
   - `deviceACL` adds devices to the `cgroup_device_acl` option, which is often required to access the devices from qemu
   - `clearEmulationCapabilities` toggles the `clear_emulation_capabilities` setting for `qemu`
   
   
   
## TODO

 - Bake the `libvirt` xml file into the system configuration
