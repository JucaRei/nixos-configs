{
  # TODO: Use a hook so that it starts only *after* the shmem device is initialized
  systemd.user.services.scream-ivshmem = {
    enable = true;
    description = "Scream IVSHMEM";
    serviceConfig = {
      ExecStart = "${pkgs.scream}/bin/scream-ivshmem-pulse /dev/shm/scream";
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
    requires = [ "pulseaudio.service" ];
  };

  virtualisation = {
    sharedMemoryFiles = {
      scream = {
        user = "richard";
        group = "qemu-libvirtd";
        mode = "666";
      };
      looking-glass = {
        user = "richard";
        group = "qemu-libvirtd";
        mode = "666";
      };
    };
    libvirtd = {
      enable = true;
      qemuOvmf = true;
      qemuRunAsRoot = false;

      onBoot = "ignore";
      onShutdown = "shutdown";

      clearEmulationCapabilities = false;
      deviceACL = [
        "/dev/input/by-path/pci-0000:0b:00.3-usb-0:2.2.4:1.0-event-mouse" # Trackball
        "/dev/input/by-path/pci-0000:0b:00.3-usb-0:2.2.3:1.0-event-kbd" # Tastatur
        "/dev/input/by-path/pci-0000:0b:00.3-usb-0:2.2.3:1.1-event-mouse" # Tastatur
        "/dev/input/by-path/pci-0000:0b:00.3-usb-0:2.2.3:1.1-mouse" # Tastatur
        "/dev/vfio/vfio"
        "/dev/vfio/2"
        "/dev/vfio/6"
        "/dev/kvm"
        "/dev/shm/scream"
        "/dev/shm/looking-glass"
      ];
    };
    vfio = {
      enable = true;
      IOMMUType = "amd";
      devices = [ "10de:1b80" "10de:10f0" ];
      blacklistNvidia = true;
      disableEFIfb = false;
      ignoreMSRs = true;
      applyACSpatch = false;
    };
    hugepages = {
      enable = true;
      defaultPageSize = "1G";
      pageSize = "1G";
      numPages = 16;
    };
  };
}
