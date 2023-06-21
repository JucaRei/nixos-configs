# Based on https://gist.github.com/sonowz/d70b03177c344f4bbbc674de5e5bb937
with import <nixpkgs> {}; let
  pname = "fix-vscode-server-binaries";
  script = pkgs.writeShellScriptBin pname ''
    set -eu -o pipefail

    SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"

    interpreter=$(patchelf --print-interpreter /run/current-system/sw/bin/sh)

    for i in ~/.vscode-server/bin/*; do
      ln -sfT "$SCRIPT_DIR/node" "$i/node"
    done

    # Replace the vscode-downloaded ripgrep binary with our faster LTO build
    for i in ~/.vscode-server/bin/*/node_modules/vscode-ripgrep/bin/rg; do
      ln -sfT /run/current-system/sw/bin/rg "$i"
    done

    # Patch the C++ tools to run on NixOS.
    for i in ~/.vscode-server/extensions/ms-vscode.*/bin/cpptools*; do
      patchelf --set-interpreter "$interpreter" "$i"
    done
  '';
in
  {}:
    stdenv.mkDerivation rec {
      name = pname;
      nodePackage = nodejs-16_x;
      src = ./.;
      installPhase = ''
        mkdir -p $out/bin
        cp ${script}/bin/${pname} $out/bin/${pname}
        cp ${nodePackage}/bin/node $out/bin/node
        chmod +x $out/bin/${pname}
      '';
      buildInputs = [script nodePackage];
    }
