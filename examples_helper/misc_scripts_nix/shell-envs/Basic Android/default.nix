{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  shellHook = ''
    echo -e "Hello world from the android nix-shell"

    tips () {
      echo -e "\nUsefull links:"
      echo -e "============================================================="
      echo -e "Recovery (TWRP)           | https://twrp.me/Devices/"
      echo -e "OS (/e/ os)               | https://doc.e.foundation/devices"
      echo -e "OS (lineageOS)            | https://lineageos.org/"
      echo -e "Android help forum (xda)  | https://www.xda-developers.com/"
      echo -e "============================================================="

      echo -e "\nCommand info:"
      echo -e "====================================================================================="
      echo -e "adb == when device is running the os / inside the adb sideload mode in the recovery"
      echo -e "fastboot == every other time when it's not adb"
      echo -e "====================================================================================="

      echo -e "\nBasic command :"
      echo -e "===================================================================================================================="
      echo -e "adb/fastboot devices                       | list the connected devices"
      echo -e "adb/fastboot reboot {bootloader, fastboot} | reboot android device to the wanted state (the arg in {} can be omited)"
      echo -e "\nadb sideload [FILE]                        | flash an os to an android device"
      echo -e "\nfastboot boot [FILE]                       | flash a recovery to an android device"
      echo -e "===================================================================================================================="
    }

    tips

    # The adb server must be run as root to be able to connect to device
    #adb kill-server
    sudo adb start-server
  '';

  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = [
    # Android default tools
    pkgs.android-tools

    # Samsung tool
    pkgs.heimdall
  ];
}
