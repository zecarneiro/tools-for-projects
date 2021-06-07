#!/bin/bash
# José M. C. Noronha

function installDependencyAngular () {
    local -a node_commands
    local -a angular_commands

    echo "Dependency Angular. Will be execute/install..."

    # Define node
    node_commands=("sudo chown -R $USER /usr/local" "sudo chown -R $USER /usr/local")
    node_commands+=("sudo chown -R $USER:$(id -gn $USER) $HOME/.config" "sudo snap install node --channel=10/stable --classic")
    printf "\nNode:\n"
    for nodeCmd in "${node_commands[@]}"; do
        printf "\t- $nodeCmd\n"
    done

    # Define angular
    angular_commands=("echo fs.inotify.max_user_watches=262144 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p")
    angular_commands+=("sudo npm install -g @angular/cli")
    printf "\nAngular:\n"
    for angularCmd in "${angular_commands[@]}"; do
        printf "\t- $angularCmd\n"
    done
    
    read -p "Continue? [y/n]: " isContinue
    if [ "$isContinue" = "y" ]; then
        printf "\nInstalling NodeJS...\n"
        for command in "${node_commands[@]}"; do
            echo "Execute: $command"
            eval $command
            printf "\n\n"
        done

        printf "\nInstalling Angular...\n"
        for command in "${angular_commands[@]}"; do
            echo "Execute: $command"
            eval $command
            printf "\n\n"
        done
    fi
}

function runTestForSpecFilesAngular () {
    echo
    echo "Jasmine allows you to prefix describe and it methods with an f (for focus?)."
    echo "So, fdescribe and fit. If you use either of these, karma will only run the relevant tests."
    echo "So, to focus the current file, you can just take the top level describe and change it to fdescribe"
    read -p "Change it and PRESS ENTER to continue..." enterPressed

    # Run test
    ng test

    # Wait to reverse changes
    echo
    read -p "Reverse all change files end PRESS ENTER to continue" enterPressed
}


# Necessary operation for angular
function angularTools () {
    while [ 1 ]; do
        setResetIsKillPID 0
        printMessage "${nameProjectArray[1]}"
        echo
        echo "0 - Clear Screen"
        echo "------"
        echo "1 - Create Project"
        echo "2 - Install With NPM"
        echo "3 - Update With NPM"
        echo "------"
        echo "4 - Generate Component"
        echo "5 - Generate Service"
        echo "6 - Generate Module"
        echo "7 - Generate Guard"
        echo "8 - Generate Module with Routers"
        echo "------"
        echo "9 - Run Server"
        echo "10 - Run Test"
        echo "11 - Run Test for Specific Spec File"
        echo "------"
        echo "Back, PRESS ENTER"
        read -p "Insert an option: " option

        case "$option" in
            0) # Clear Screen
                clearScreen
            ;;
            1) # New
                read -p "Insert name of project: " nameProject
                if [ -n "$nameProject" ]; then
                    echo "Creating..."
                    ng new "$nameProject"
                fi
            ;;
            2) # Install
                echo "Installing..."
                npm install
            ;;
            3) # Update
                echo "Updating..."
                npm update
            ;;
            4|5|6|7|8) # Generate
                local command="ng generate"
                read -p "Insert name or full path(...path/filename): " fileName
                
                if [ -n "$fileName" ]; then
                    echo "Generating..."
                    if [ $option -eq 4 ]; then
                        $command component "$fileName"
                    elif [ $option -eq 5 ]; then
                        $command service "$fileName"
                    elif [ $option -eq 6 ]; then
                        $command module "$fileName"
                    elif [ $option -eq 7 ]; then
                        $command guard "$fileName"
                    elif [ $option -eq 8 ]; then
                        $command module --routing=true "$fileName"
                    fi
                fi
            ;;
            9) # Run
                # Clear screen
                clearScreen

                echo "Running..."

                # Set to get signal
                setHandler

                # Execute
                ng serve --liveReload=false --aot=true &

                # Get pid of process
                pid="$!"

                # Wait
                waitProcessToKill
            ;;
            10) # Test
                echo "Running Test..."
                ng test
            ;;
            11) # Test Specific spec file
                runTestForSpecFilesAngular
            ;;
            *) # Back
                break
            ;;
        esac
        printf "\n\n"
    done
}