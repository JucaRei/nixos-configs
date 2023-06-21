#My VFIO setup for a Windows 11 VM in NixOS on a Ryzen 3700x with an Nvidia 3070ti passed through to the VM
let
  iommuIds = [
    "10de:2482" # 3070 Ti Graphics
    "10de:228b" # 3070 Ti Audio
  ];
in
  {
    pkgs,
    lib,
    config,
    username,
    home-manager,
    ...
  }: {
    options.vfio.enable = with lib;
      mkEnableOption "Configure the machine for VFIO";

    config = let
      cfg = config.vfio;
    in {
      boot = {
        initrd.kernelModules = [
          "vfio_pci"
          "vfio"
          "vfio_iommu_type1"
          "vfio_virqfd"

          "nvidia"
          "nvidia_modeset"
          "nvidia_uvm"
          "nvidia_drm"
        ];

        kernelParams =
          [
            # enable IOMMU
            "amd_iommu=on"
          ]
          ++ lib.optional cfg.enable
          # isolate the GPU
          ("vfio-pci.ids=" + lib.concatStringsSep "," iommuIds);
      };

      hardware.opengl.enable = true;

      virtualisation = with pkgs; {
        spiceUSBRedirection.enable = true;
        libvirtd.enable = true;
        libvirtd.extraConfig = ''
          uri_default = "qemu:///system"
        '';
        libvirtd.qemu = {
          package = unstable.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [
            ((unstable.OVMFFull.override
              {
                secureBoot = true;
                tpmSupport = true;
                csmSupport = true;
                httpSupport = true;
              })
            .fd)
          ];
        };
      };

      systemd.tmpfiles.rules = [
        "f /dev/shm/looking-glass 0660 ${username} qemu-libvirtd -"
        "f /dev/shm/scream 0660 ${username} qemu-libvirtd -"
      ];

      environment.systemPackages = with pkgs; [
        virt-manager
        pciutils
        looking-glass-client
      ];

      systemd.user.services.scream = {
        enable = true;
        description = "Scream IVSHMEM";
        serviceConfig = {
          ExecStartPre = "/run/current-system/sw/bin/sleep 5";
          ExecStart = "${pkgs.scream}/bin/scream -m /dev/shm/scream";
          Restart = "always";
          RestartSec = 2;
        };
        wantedBy = ["default.target"];
        requires = ["pipewire-pulse.service"];
      };

      home-manager.users.${username} = {
        xdg.desktopEntries.looking-glass-client = {
          exec = "looking-glass-client";
          icon = "lg-logo";
          name = "Looking Glass Client";
          genericName = "View Virtual Machine Desktops";
          type = "Application";
          terminal = false;
        };
      };
    };
  }
## Note that I have a bunch of other PCI devices (hard drives, webcam etc) passed through
## on the VM configuration that you'll probably want to remove from the VM configuration.
##
## You'll need to install the drivers for Looking Glass and Scream on the VM while running
## QXL video (the slow, laggy one that doesn't use your GPU) before you can get Looking Glass
## working, and also IDDSampleDriver from scoop so that you can use your GPU with Looking Glass
## without needing to buy and use a dummy HDMI plug.

