function installDependencyCake () {
    local -a curl_commands
    local -a php_commands
    local -a composer_commands

    echo "Dependency CakePHP. Will be execute/install..."

    # Define php
    php_commands=("snmp-mibs-downloader" "php-cli" "php-fpm" "php-intl" "php-mbstring" "php-xml")
    php_commands+=("php-curl" "php-gd" "php-pear" "php-imagick" "php-imap" "php-memcache" "php-pspell")
    php_commands+=("php-recode" "php-snmp" "php-tidy" "php-xmlrpc" "php-sqlite3" "php-mysql" "php")
    printf "\nPHP:\n"
    for phpCmd in "${php_commands[@]}"; do
        printf "\t- sudo apt install $phpCmd\n"
    done

    # Define curl
    curl_commands=("sudo apt install curl")
    printf "\nCurl:\n"
    for curlCmd in "${curl_commands[@]}"; do
        printf "\t- $curlCmd\n"
    done

    # Define composer
    composer_commands=("curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer")
    printf "\nComposer:\n"
    for composerCmd in "${composer_commands[@]}"; do
        printf "\t- $composerCmd\n"
    done

    read -p "Continue? [y/n]: " isContinue
    if [ "$isContinue" = "y" ]; then
        printf "\nInstalling PHP...\n"
        for command in "${php_commands[@]}"; do
            echo "Execute: sudo apt install $command"
            sudo apt install $command
            printf "\n\n"
        done

        echo
        
        printf "\nInstalling Curl...\n"
        for command in "${curl_commands[@]}"; do
            echo "Execute: $command"
            eval $command
            printf "\n\n"
        done

        printf "\nInstalling Composer...\n"
        for command in "${composer_commands[@]}"; do
            echo "Execute: $command"
            eval $command
            printf "\n\n"
        done
    fi
}

# Other CakePHP method
function cakePhpOther () {
    local operation="$1"
    local nameProject="$2"
    local logsPath="tmp"
    local tmpPath="logs"

    if [ -n "$nameProject" ]; then
        logsPath="$nameProject/logs"
        tmpPath="$nameProject/tmp"
    fi

    if [ "$operation" -eq 0 ]; then # Create tmp and log folder
        mkdir -p "$logsPath"
        mkdir -p "$tmpPath"
    elif [ "$operation" -eq 1 ]; then # Set full permission on tmp and log folder
        sudo chmod -R 777 "$logsPath"
        sudo chmod -R 777 "$tmpPath"
    fi
}

function setCakeBashCompletion () {
    echo "Set Cake Bash Completion..."
    local _file_cake_script="/etc/bash_completion.d/cake"

    # Install bash completion
    sudo apt install bash-completion -y

    # Install script
    if [ -f "$filesTemplatePath/cake" ]; then
       sudo cp "$filesTemplatePath/cake" "$_file_cake_script"
    else
        echo "Error on set bash cake complete"
    fi
}

# Run Test for cake php
function runTestCakePhp () {
    while [ 1 ]; do
        echo
        echo "#### Global Without plugin ####"
        echo "0 - Global Test"
        echo "1 - Test Specific file PHP"
        echo "2 - Test Specific Method"
        echo "#### Plugin ####"
        echo "3 - Global Test on Plugin"
        echo "4 - Test Specific file PHP on Plugin"
        echo "5 - Test Specific Method on Plugin"
        echo "########"
        echo "Back, PRESS ENTER"
        read -p "Insert an option: " option

        # Exit
        if [ -z "$option" ]; then
            break
        fi

        echo "Set Permission on necessary path!!!"
        cakePhpOther 1

        # Execute Global
        if [ "$option" = "0" ]||[ "$option" = "1" ]||[ "$option" = "2" ]; then
            local withDebug=""
            read -p "With Debug: (y/N) " isDebug
            if [ "$isDebug" = "y" ]; then
                withDebug=" --debug"
            fi

            if [ "$option" = "0" ]; then
                # Run
                vendor/bin/phpunit$withDebug

            elif [ "$option" = "1" ]||[ "$option" = "2" ]; then
                read -p "Insert full path for file (tests/full/path/nameFile): " fileName
                if [ -f "$fileName" ]; then
                    if [ "$option" = "1" ]; then
                        vendor/bin/phpunit$withDebug "$fileName"
                    else
                        read -p "Insert name of method: " methodName
                        vendor/bin/phpunit$withDebug --filter "$methodName" "$fileName"
                    fi
                else
                    echo "Not Exist: $fileName"
                fi
            fi
        # Execute Plugin
        elif [ "$option" = "3" ]||[ "$option" = "4" ]||[ "$option" = "5" ]; then
            read -p "Insert name of plugin: " pluginName
            if [ -n "$pluginName" ]; then
                local pluginPath="plugins/$pluginName"

                local withDebug=""
                read -p "With Debug: (y/N) " isDebug
                if [ "$isDebug" = "y" ]; then
                    withDebug=" --debug"
                fi

                if [ "$option" = "3" ]; then
                    cd "$pluginPath" && ../../vendor/bin/phpunit$withDebug

                elif [ "$option" = "4" ]||[ "$option" = "5" ]; then
                    read -p "Insert full path for file (tests/full/path/nameFile): " fileName
                    if [ -f "$pluginPath/$fileName" ]; then
                        if [ "$option" = "4" ]; then
                            cd "$pluginPath" && ../../vendor/bin/phpunit$withDebug "$fileName"
                        else
                            read -p "Insert name of method: " methodName
                            cd "$pluginPath" && ../../vendor/bin/phpunit$withDebug --filter "$methodName" "$fileName"
                        fi
                    else
                        echo "Not Exist: $fileName"
                    fi
                fi
            else
                echo "Invalid plugin name!!!"
            fi
        fi
    done    
}


# Necessary operation for cakephp
function cakePhpTools () {
    # Execute
    while [ 1 ]; do
        command="bin/cake bake"
        pluginInfo=""
        setResetIsKillPID 0
        printMessage "${nameProjectArray[2]}"
        echo
        echo "0 - Clear Screen"
        echo "------"
        echo "1 - Create Project"
        echo "2 - Install With Composer"
        echo "3 - Update With Composer"
        echo "------"
        echo "4 - Generate All"
        echo "5 - Generate Controller"
        echo "6 - Generate Model"
        echo "7 - Generate Template"
        echo "------"
        echo "8 - Generate Component"
        echo "9 - Generate Shell"
        echo "10 - Generate Task"
        echo "------"
        echo "11 - Generate Fixture"
        echo "12 - Generate Test"
        echo "------"
        echo "13 - Get Logs"
        echo "14 - Run Test With PHPUnit"
        echo "15 - Set Permission"
        echo "16 - Set Bash Completion"
        echo "------"
        echo "17 - Create Plugin"
        echo "------"
        echo "Back, PRESS ENTER"
        read -p "Insert an option: " option

        case "$option" in
            4|5|6|7|8|11|12)
                read -p "On Plugin? (y/N) " isPlugin
                if [ "$isPlugin" = "y" ]; then
                    read -p "Insert name of Plugin: " pluginName
                    if [ ! -d "plugins/$pluginName" ]; then
                        echo "Not exist plugin with name: $pluginName"
                        echo
                        continue
                    else
                        pluginInfo="--plugin $pluginName"
                    fi
                fi
            ;;
            *) # Default
        esac

        case "$option" in
            0) # Clear Screen
                clearScreen
            ;;
            1) # New
                read -p "Insert name of project: " nameProject
                if [ -n "$nameProject" ]; then
                    echo "Creating..."

                    # Create
                    composer create-project --prefer-dist cakephp/app "$nameProject"

                    # Create tmp and log folder
                    cakePhpOther 0 "$nameProject"

                    # Set full permission on tmp and log folder
                    cakePhpOther 1 "$nameProject"
                fi
            ;;
            2) # Install
                echo "Installing..."
                composer install

                # Set full permission on tmp and log folder
                cakePhpOther 1
            ;;
            3) # Update
                echo "Updating..."
                composer update

                # Set full permission on tmp and log folder
                cakePhpOther 1
            ;;
            4|5|6|7) # Generate
                read -p "Insert name of database: " databaseName

                if [ -n "$databaseName" ]; then
                    echo "Generating..."
                    if [ $option -eq 4 ]; then
                        $command all $pluginInfo "$databaseName"
                    elif [ $option -eq 5 ]; then
                        $command controller $pluginInfo "$databaseName"
                    elif [ $option -eq 6 ]; then
                        $command model $pluginInfo "$databaseName"
                    elif [ $option -eq 7 ]; then
                        $command template $pluginInfo "$databaseName"
                    fi
                fi
            ;;
            8|9|10) # Generate
                read -p "Insert name of class name: " className

                if [ -n "$className" ]; then
                    echo "Generating..."
                    if [ $option -eq 8 ]; then
                        $command component $pluginInfo "$className"
                    elif [ $option -eq 9 ]; then
                        $command shell "$className"
                    elif [ $option -eq 10 ]; then
                        $command task "$className"
                    fi
                fi
            ;;
            11|12) # Tests
                if [ $option -eq 11 ]; then
                    read -p "Insert name of database name: " classDatabaseTestName
                else
                    read -p "Insert name of class name: " classDatabaseTestName
                fi

                if [ -n "$classDatabaseTestName" ]; then
                    if [ $option -eq 11 ]; then
                        $command fixture $pluginInfo "$classDatabaseTestName"
                    elif [ $option -eq 12 ]; then
                        echo "1 - Entity"
                        echo "2 - Table"
                        echo "3 - Controller"
                        echo "4 - Component"
                        read -p "Insert test option: " testOption
                        local subcommand=""
                        case "$testOption" in
                            1) # Entity
                                subcommand="Entity"
                            ;;
                            2) # Table
                                subcommand="Table"
                            ;;
                            3) # Controller
                                subcommand="Controller"
                            ;;
                            4) # Component
                                subcommand="Component"
                            ;;
                            *) echo "Invalid option"
                            ;;
                        esac

                        if [ -n "$subcommand" ]; then
                            $command test $pluginInfo "$subcommand" "$classDatabaseTestName"
                        fi
                    fi
                fi
            ;;
            13) # Get logs

                # Clear screen
                clearScreen 1

                # Set to get signal
                setHandler

                # Execute tail
                tail -F logs/* 2>&1 &

                # Get pid of process
                pid="$!"

                # Wait
                waitProcessToKill
            ;;
            14) # Run PHPUnit
                runTestCakePhp
            ;;
            15) # Set Permission
                # Set full permission on tmp and log folder
                cakePhpOther 1
            ;;
            16) # Set Bash Completion
                setCakeBashCompletion
            ;;
            17) # Create Plugin
                read -p "Insert Name of Plugin(without space): " pluginCreateName
                pluginCreateName="${pluginCreateName//" "}"
                if [ -n "$pluginCreateName" ]; then
                    echo "Create Plugin..."
                    $command plugin "$pluginCreateName"
                    composer dumpautoload
                fi
            ;;
            *) # Back
                break
            ;;
        esac
        printf "\n\n"
    done
}