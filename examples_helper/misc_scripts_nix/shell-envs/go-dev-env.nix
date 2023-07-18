{pkgs ? import <nixpkgs> {}}:
with pkgs; let
  goVersion = "1.19";
in
  mkShell {
    buildInputs = [
      go_
      ${goVersion}
      golint
      gofmt
      godoc
      protobuf
      protoc-gen-go
      nodejs
      npm
    ];

    postBuild = ''
      # Run `go install` to install the `sqlc` tool
      go install github.com/kyleconroy/sqlc/cmd/sqlc
    '';
  }
# nix-shell go-node-shell.nix

