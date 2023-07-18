{
  description = "InTape backend";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [python3Packages.poetry gcc];
        shellHook = ''
          export STATE_PREFIX="intape"
          export STATE_FILE_PREFIX="$STATE_PREFIX"
          git status &> /dev/null
          if [ $? == 0 ]; then
            export GIT_REV="$(git rev-parse --abbrev-ref HEAD)"
            # Replace "/" with "-" to avoid issues with paths
            export GIT_REV="$(echo $GIT_REV | sed -r 's/\//-/g')"

            if [ "$GIT_REV" != "$(cat /tmp/$STATE_FILE_PREFIX-branch)" ]; then
              echo "Branch changed, resetting state"
              rm -f /tmp/*$STATE_FILE_PREFIX*
            fi
            echo $GIT_REV > /tmp/$STATE_FILE_PREFIX-branch

            export STATE_FILE_PREFIX="$STATE_FILE_PREFIX-$GIT_REV"
          else
            echo "Git binary not found, not setting branch-based STATE_FILE_PREFIX"
          fi

          echo "Setting environment variables for development:"
          export DB_URL="postgresql+asyncpg://user:password@localhost:5432/db"
          export IPFS_URL="http://127.0.0.1:9094"
          export SECRET="1234"
          echo " - DB_URL: '$DB_URL'"
          echo " - IPFS_URL: '$IPFS_URL'"
          echo " - SECRET: '$SECRET'"

          if [ ! -f /tmp/poetry-$STATE_FILE_PREFIX-init ]; then
            echo "Installing dependencies..."
            poetry install

            touch /tmp/poetry-$STATE_FILE_PREFIX-init
          else
            echo "Dependencies already installed, skipping..."
            echo " - (delete '/tmp/poetry-$STATE_FILE_PREFIX-init' to force reinstall)"
          fi

          if [ ! -f /tmp/containers-$STATE_FILE_PREFIX-init ]; then
            echo "Starting containers..."
            export DOCKER_FOUND=0
            export DOCKER_CHECK="ps"

            echo "Checking for container backend..."

            if [ $DOCKER_FOUND != 1 ]; then
              echo "Trying docker..."
              export DOCKER_BIN="docker"
              $DOCKER_BIN $DOCKER_CHECK &> /dev/null
              if [ $? == 0 ]; then
                export DOCKER_FOUND=1
              fi
            fi

            if [ $DOCKER_FOUND != 1 ]; then
              echo "Docker not found, trying podman..."
              export DOCKER_BIN="podman"
              $DOCKER_BIN $DOCKER_CHECK &> /dev/null
              if [ $? == 0 ]; then
                export DOCKER_FOUND=1
              fi
            fi

            if [ $DOCKER_FOUND == 1 ]; then
              echo "Using '$DOCKER_BIN' container backend"

              echo "Launching db..."
              $DOCKER_BIN rm -f $STATE_PREFIX-db &> /dev/null || true
              $DOCKER_BIN run -d --rm \
                --name $STATE_PREFIX-db -p 5432:5432 \
                -e POSTGRES_PASSWORD="password" \
                -e POSTGRES_USER="user" \
                -e POSTGRES_DB="db" \
                docker.io/postgres:alpine

              echo "Launching ipfs..."
              $DOCKER_BIN rm -f $STATE_PREFIX-ipfs &> /dev/null || true
              $DOCKER_BIN run -d --rm \
                --name $STATE_PREFIX-ipfs -p 5001:5001 \
                docker.io/ipfs/kubo

              echo "Launching ipfs-cluster..."
              $DOCKER_BIN rm -f $STATE_PREFIX-ipfs-cluster &> /dev/null || true
              $DOCKER_BIN run -d --rm \
                --name $STATE_PREFIX-ipfs-cluster --net host \
                -e CLUSTER_RESTAPI_HTTPLISTENMULTIADDRESS="/ip4/0.0.0.0/tcp/9094" \
                docker.io/ipfs/ipfs-cluster

              echo "Waiting 1 second for containers to start..."
              sleep 1

              echo "Applying migrations..."
              poetry run alembic upgrade head
            else
              echo "Container engine not found, skipping environment initialization"
            fi

            touch /tmp/containers-$STATE_FILE_PREFIX-init
          else
            echo "Containers already started, skipping..."
            echo " - (delete '/tmp/containers-$STATE_FILE_PREFIX-init' to force restart them)"
          fi
        '';
      };
    });
}
