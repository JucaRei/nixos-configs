#!/bin/sh

set -eu -o pipefail -o verbose

cd ~/bin
nix-build fix-vscode-server-binaries.nix
./result/bin/fix-vscode-server-binaries
