#!/bin/bash
# José M. C. Noronha

# Global
declare arg="$1"
declare bin_path="/usr/bin"
declare install_path="/opt/tools_for_projects"
declare tools_script="toolsForProjects.sh"

function _install () {
    sudo chmod -R 777 .
    sudo cp -r . "$install_path"
    sudo ln -sf "$install_path/$tools_script" $bin_path/tools_for_projects
}

function _uninstall () {
    sudo rm -r "$install_path"
}


function main () {
    case "$arg" in
        "-i")
            echo "Install..."
            _install
        ;;
        "-u")
            echo "Uninstall..."
            _uninstall
        ;;
        *)
            echo "$0 -i|-u (Install|Uninstall)"
        ;;
    esac
}
main

