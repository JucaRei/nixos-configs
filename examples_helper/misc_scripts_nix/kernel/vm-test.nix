{
  config,
  lib,
  pkgs,
  ...
}: let
  #bcachefs-tools = (pkgs.callPackage ./ {doCheck = false;});
  kernel = pkgs.callPackage ./ktest/kernel_install.nix {
    src = ./bcachefs;
    srcBuildRoot = ./ktest/ktest-out/kernel_build.x86_64;
  };
in {
  boot.kernelParams = [
    "quiet"
    "noexec=off"
    "oops=panic"
  ];

  boot.kernelPackages = pkgs.linuxPackagesFor kernel;
  boot.initrd.includeDefaultModules = false;
  environment.systemPackages = with pkgs; [
    linuxPackages.perf
    tmux
    htop
    sysstat
    killall
    fio
    bcachefs-tools
    #trace-cmd
    git
    git-crypt
    vim
  ];
  services.getty.autologinUser = "root";
  virtualisation = {
    memorySize = 1024 * 16;
    #graphics = true;
    cores = 6;
    qemu.options = [
      "-echr 2" # tmux/screen support
      "-s" # gdb server
      "-rtc"
      "clock=vm"
    ];
  };
  system.stateVersion = "21.11";
}
