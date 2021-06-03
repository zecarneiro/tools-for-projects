#!/bin/bash

exit_err() {
    [ $# -gt 0 ] && echo "fatal: $*" 1>&2
    exit 1
}

#
# Adam Sharp
# Aug 21, 2013
#
# Usage: Add it to your PATH and `git remove-submodule path/to/submodule`.
#
# Does the inverse of `git submodule add`:
#  1) `deinit` the submodule
#  2) Remove the submodule from the index and working directory
#  3) Clean up the .gitmodules file
delete_submodule() {
    submodule_name=$(echo "$1" | sed 's/\/$//')
    shift

    if git submodule status "$submodule_name" >/dev/null 2>&1; then
        git submodule deinit -f "$submodule_name"
        git rm -f "$submodule_name"

        git config -f .gitmodules --remove-section "submodule.$submodule_name"
        if [ -z "$(cat .gitmodules)" ]; then
            git rm -f .gitmodules
        else
            git add .gitmodules
        fi
        git rm --cached "$submodule_name"
        rm -rf ".git/modules/$submodule_name"
    else
        exit_err "Submodule '$submodule_name' not found"
    fi
}

main() {
    echo "JOSE"
    operation="$1"; shift
    case "${operation}" in
        del-submodule) delete_submodule "$@" ;;
        update-submodule) update_submodule ;;
        update-tags) update_tags ;;
        add) add "$@" ;;
        rebase) rebase "$@" ;;
        *)
            echo "$(basename "$0") del-submodule|update-submodule|update-tags|add|rebase [value]"
        ;;
    esac
}
main "$@"