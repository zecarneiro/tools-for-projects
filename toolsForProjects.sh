#!/bin/bash
# José M. C. Noronha

# Global
declare nameProjectArray=("Install Dendencies" "Angular" "CakePHP" "Docker" "DataBases" "WebServer" "Network")
declare currentPath="$(echo $PWD)"
declare pid
declare isKillPID="0"
declare filesTemplatePath="/opt/tools_for_projects/files"

################################################
# Dependency Tools
################################################
function dependenciesTools () {
    # Execute
    while [ 1 ]; do
        echo "##########################"
        echo "Selected Tool: ${nameProjectArray[0]}"
        # Print Menu
        echo
        echo "0 - Clear Screen"
        echo "------"
        echo "1 - Angular"
        echo "2 - CakePHP"
        echo "3 - Docker"
        echo "4 - Databases"
        echo "5 - WebServer"
        echo "------"
        echo "Back, PRESS ENTER"
        read -p "Insert an option: " option

        if [ -n "$option" ]; then
            clearScreen
        fi

        case "$option" in
            0) # Clear Screen
                clearScreen
            ;;
            1) # Angular
                installDependencyAngular
            ;;
            2) # CakePHP
                installDependencyCake
            ;;
            3) # Docker
                installDependencyDocker
            ;;
            4) # Databases
                installDependencyDatabases
            ;;
            5) # WebServer
                installDependencyWebServer
            ;;
            *) # Exit
                break
            ;;
        esac
        printf "\n\n"
    done
}

################################################
# Main
################################################
# Main
function main () {
    while [ 1 ]; do
        # Print Menu
        echo "Tools necessary for projects"
        echo "0 - Clear Screen"
        echo "----------"
        echo "1 - Install Dependencies"
        echo "2 - Angular"
        echo "3 - CakePHP"
        echo "4 - Docker"
        echo "5 - Databases"
        echo "6 - Web Server"
        echo "7 - Network"
        echo "----------"
        echo "Exit, PRESS ENTER"
        read -p "Insert an option: " option

        case "$option" in
            0) # Clear Screen
                clearScreen
            ;;
            1) # Install Dependencies
                dependenciesTools
            ;;
            2) # Angular
                angularTools
            ;;
            3) # CakePHP
                cakePhpTools
            ;;
            4) # Docker
                dockerTools
            ;;
            5) # Databases
                databaseTools
            ;;
            6) # Webserver
                webserverTools
            ;;
            7) # Network
                networkTools
            ;;
            *) # Exit
                break
            ;;
        esac
    done
    exitMethod
}
main
