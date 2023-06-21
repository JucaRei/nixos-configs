# Adapted from https://github.com/bennofs/nix-index/blob/master/command-not-found.sh
# Improved home-manager nix-locate configuration, with an auto-updated index and a better command-not-found handler

command_not_found_handle() {
    if [ -n "${MC_SID-}" ] || ! [ -t 1 ]; then
        echo >&2 "$1: command not found"
        return 127
    fi

    echo -n "searching nix-index..."
    ATTRS=$(@nix-locate@ --minimal --no-group --type x --type s --top-level --whole-name --at-root "/bin/$1")

    case $(echo -n "$ATTRS" | grep -c "^") in
    0)
        echo >&2 -ne "$(@tput@ el1)\r"
        echo >&2 "$1: command not found"
        ;;
    *)
        echo >&2 -ne "$(@tput@ el1)\r"
        echo >&2 "The program ‘$(@tput@ setaf 4)$1$(@tput@ sgr0)’ is currently not installed."
        echo >&2 "It is provided by the following derivation(s):"
        while read ATTR; do
            ATTR=$(echo "$ATTR" | sed 's|\.out$||') # Strip trailing '.out'
            echo >&2 "  $(@tput@ setaf 12)nixpkgs#$(@tput@ setaf 4)$ATTR$(@tput@ sgr0)"
        done <<<"$ATTRS"
        ;;
    esac

    return 127
}

command_not_found_handler() {
    command_not_found_handle $@
    return $?
}
