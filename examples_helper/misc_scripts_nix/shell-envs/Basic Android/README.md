# Android nix-shell
This is a basic sample of a nix-shell for android flashing

## Installation
```sh
curl --progress-bar \
 https://gist.githubusercontent.com/default.nix > /tmp/android-shell.nix \
 && nix-shell /tmp/android-shell.nix
```