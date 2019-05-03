#!/bin/bash
# José M. C. Noronha

# Global
declare nameProjectArray=("Install Dendencies" "Angular" "CakePHP" "Docker" "DataBases" "WebServer" "Network")
declare currentPath="$(echo $PWD)"
declare pid
declare isKillPID="0"
declare filesTemplatePath="/opt/tools_for_projects/files"

################################################
# Generic
################################################
# Set Handler to get singal
function setHandler () {
    # Help
    # SIGINT: CTRL+C
    # SIGQUIT: CTRL+\
    # SIGTSTP: CTRL+Z

    # Execute killPID when signal detected
    trap killPID SIGINT SIGQUIT SIGTSTP
}

# Set or reset isKill PID
function setResetIsKillPID () {
    local isSet="$1"

    if [ $isSet -eq 1 ]; then
        isKillPID="1"
    else
        if [ $isKillPID -eq 1 ]; then
            clearScreen 1
            isKillPID="0"
        fi
    fi
}

# Wait any process to kill
function waitProcessToKill () {
    read -p ""
}

# Kill pid
function killPID () {
    kill "$pid"
    
    # Clear screen
    clearScreen 1

    setResetIsKillPID 1

    # Print message
    echo "Press ENTER TO CONTINUE"
}

# Print selected project
function printMessage () {
    echo "##########################"
    warningInfo
    echo "Selected Tool: $1"
}

# Show Warning message
function warningInfo () {
    echo "Current Path: $currentPath"
    echo "Please check if current path is ROOT Project"
}

# Exit quit script
function exitMethod () {
    exit 1
}

# Clear screen
function clearScreen () {
    printf "\033c"
}

################################################
# Angular Projects
################################################
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
    angular_commands=("echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p")
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
        echo "------"
        echo "8 - Run Server"
        echo "9 - Run Test"
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
            4|5|6|7) # Generate
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
                    fi
                fi
            ;;
            8) # Run
                # Clear screen
                clearScreen

                echo "Running..."

                # Set to get signal
                setHandler

                # Execute
                ng serve &

                # Get pid of process
                pid="$!"

                # Wait
                waitProcessToKill
            ;;
            9) # Test
                echo "Running Test..."
                ng test
            ;;
            *) # Back
                break
            ;;
        esac
        printf "\n\n"
    done
}

################################################
# CakePHP Projects
################################################
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

# Necessary operation for cakephp
function cakePhpTools () {
    local command="bin/cake bake"

    # Execute
    while [ 1 ]; do
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
                        $command all "$databaseName"
                    elif [ $option -eq 5 ]; then
                        $command controller "$databaseName"
                    elif [ $option -eq 6 ]; then
                        $command model "$databaseName"
                    elif [ $option -eq 7 ]; then
                        $command template "$databaseName"
                    fi
                fi
            ;;
            8|9|10) # Generate
                read -p "Insert name of class name: " className

                if [ -n "$className" ]; then
                    echo "Generating..."
                    if [ $option -eq 8 ]; then
                        $command component "$className"
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
                        $command fixture "$classDatabaseTestName"
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
                            $command test "$subcommand" "$classDatabaseTestName"
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
                # Set full permission on tmp and log folder
                cakePhpOther 1

                # Run
                vendor/bin/phpunit
            ;;
            15) # Set Permission
                # Set full permission on tmp and log folder
                cakePhpOther 1
            ;;
            16) # Set Bash Completion
                setCakeBashCompletion
            ;;
            *) # Back
                break
            ;;
        esac
        printf "\n\n"
    done
}

################################################
# Docker Tools
################################################
function installDependencyDocker () {
    local -a curl_commands
    local -a docker_commands
    local -i index="0"

    echo "Dependency Docker. Will be execute/install..."

    # Define curl
    curl_commands=("sudo apt install curl")
    printf "\nCurl:\n"
    for curlCmd in "${curl_commands[@]}"; do
        printf "\t- $curlCmd\n"
    done

    # Define docker
    docker_commands=("curl -sSL https://get.docker.com | sh" "sudo usermod -aG docker $USER")
    docker_commands+=("docker-ce-cli" "containerd.io" "docker-compose" "docker-containerd")
    printf "\nDocker:\n"
    for dockerCmd in "${docker_commands[@]}"; do
        if (( $index == 0 ))||(( $index == 1 )); then
            printf "\t- $dockerCmd\n"
            index=$index+1
        else
            printf "\t- sudo apt install $dockerCmd\n"
        fi
    done

    read -p "Continue? [y/n]: " isContinue
    if [ "$isContinue" = "y" ]; then        
        printf "\nInstalling Curl...\n"
        for command in "${curl_commands[@]}"; do
            echo "Execute: $command"
            eval $command
            printf "\n\n"
        done

        printf "\nInstalling Docker...\n"
        index="0"
        for command in "${docker_commands[@]}"; do
            if (( $index == 0 ))||(( $index == 1 )); then
                echo "Execute: $command"
                eval $command
                index=$index+1
            else
                echo "Execute: sudo apt install $command"
                sudo apt install $command
            fi
            printf "\n\n"
        done
    fi
}

function printListContainers () {
    printf "List of Containers...\n\n"
    docker ps
}

function printListImages () {
    printf "List of Images...\n"
    docker images
}

function loginToContainer () {
    printListContainers
    printf "\n\n"
    read -p "Insert Container ID: " cotainerId

    if [ -n "$cotainerId" ]; then
        docker exec -i -t $cotainerId /bin/bash
    fi
}

function removeContainers () {
    echo "Remove docker Containers..."
    printListContainers
    printf "\n\n"
    read -p "Insert Container ID: " cotainerId
    docker-compose rm $cotainerId
}

function removeImages () {
    echo "Remove docker Images..."
    printListImages
    printf "\n\n"
    read -p "Insert Image ID: " imageId
    docker rmi $imageId
}

function showIpAddressContainer () {
    printf "Show IP Address...\n"
    printListContainers
    printf "\n\n"
    read -p "Insert Container ID: " cotainerId
    if [ -n "$cotainerId" ]; then
        printf "IP: "
        docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $cotainerId
        printf "\n\n"
    fi
}

function allowOrDenyUFW () {
    local -i isAllow="$1"

    if [ $isAllow == "0" ]; then
        read -p "Do you want alow firewall UFW for your container[y/N]: " response
        if [ "$response" = "y" ]; then
            showIpAddressContainer
            read -p "Please, insert IP Address: " ip_address

            if [ -n "$ip_address" ]; then
                sudo ufw allow from $ip_address
            fi
        fi
    elif [ $isAllow == "1" ]; then
        read -p "Do you want deny firewall UFW for your container[y/N]: " response
        if [ "$response" = "y" ]; then
            showIpAddressContainer
            read -p "Please, insert IP Address: " ip_address

            if [ -n "$ip_address" ]; then
                sudo ufw deny from $ip_address
                sudo ufw delete deny from $ip_address
            fi
        fi
    fi
}

function dockerTools () {
    while [ 1 ]; do
        printMessage "${nameProjectArray[3]}"
        echo
        echo "0 - Clear Screen"
        echo "----------"
        echo "1 - Build with docker compose"
        echo "2 - Up with docker compose"
        echo "3 - Up with docker compose and give you shell"
        echo "4 - Down with docker compose"
        echo "5 - Login to docker already in execution"
        echo "----------"
        echo "6 - Print list of docker containers"
        echo "7 - Print list of docker images"
        echo "8 - Remove Container with docker compose"
        echo "9 - Remove Images with docker"
        echo "10 - Purging All Unused or Dangling Images, Containers, Volumes, and Networks"
        echo "11 - Show IP Address of container"
        echo "----------"
        echo "12 - Allow firewall UFW for container"
        echo "13 - Deny firewall UFW for container"
        echo "----------"
        echo "Back, PRESS ENTER"
        read -p "Insert a option: "  optionInsertedByUser

        # Execute user option
        case "$optionInsertedByUser" in
            0) # Clear Screen
                clearScreen
            ;;
            1) # Build
                echo "Build..."
                docker-compose build --no-cache
            ;;
            2) # Up
                echo "Up..."
                docker-compose up
            ;;
            3) # Up and return shell to user
                echo "Up and give shell..."
                docker-compose up -d
            ;;
            4) # Down
                echo "Down..."
                docker-compose down
            ;;
            5) # Login to container
                echo "Login to container..."
                loginToContainer
            ;;
            6) # Print List of container
                printListContainers
            ;;
            7) # Print List of images
                printListImages
            ;;
            8) # Remove Containers
                removeContainers
            ;;
            9) # Remove Images
                removeImages
            ;;
            10) # Purging All Unused or Dangling Images, Containers, Volumes, and Networks
                echo "Stopping all containers..."
                docker kill $(docker ps -q) # Kill all docker container running
                printf "Stopping all containers Done.\n\n"

                # Delete All
                docker system prune -a
            ;;
            11) # Show Ip Address
                showIpAddressContainer
            ;;
            12) # Allow firewall UFW for container
                allowOrDenyUFW 0
            ;;
            13) # Deny firewall UFW for container
                allowOrDenyUFW 1
            ;;
            *) # Back
                break
            ;;
        esac
        printf "\n\n"
    done
}

################################################
# Database Tools
################################################
function getDataBase () {
    echo "Selection of Database" >&2
    echo "1 - MySQL" >&2
    echo "2 - MariaDb" >&2
    echo "ENTER TO CANCEL" >&2
    read -p "Insert an option: " option
    echo "$option"
}

function installDependencyDatabases () {
    local database_selected="$(getDataBase)"
    local -a database_commands
    local -i index="0"
    local name_database
    local commandDatabase
    local userDatabase
    local -a query

    echo "Dependency Databases. Will be execute/install..."

    if [ "$database_selected" = "1" ]||[ "$database_selected" = "2" ]; then
        userDatabase="root"

        # Define
        if [ "$database_selected" = "1" ]; then
            name_database="MySQL"
            database_commands=("mysql-server" "mysql-client")
        else
            name_database="MariaDb"
            database_commands=("mariadb-server" "mariadb-client")
        fi
        database_commands+=("sudo mysql_secure_installation")
        
        printf "\n$name_database:\n"
        for databaseCmd in "${database_commands[@]}"; do
            if (( $index != 2 )); then
                printf "\t- sudo apt install $databaseCmd\n"
            else
                printf "\t- $databaseCmd\n"
            fi
            index=$index+1
        done

        read -p "Continue? [y/n]: " isContinue
        if [ "$isContinue" = "y" ]; then
            index="0"     
            printf "\nInstalling $name_database...\n"
            for command in "${database_commands[@]}"; do
                if (( $index != 2 )); then
                    echo "Execute: sudo apt install $command"
                    sudo apt install $command
                else
                    echo "Execute: $command"
                    printf "\n### CONFIG OPTIONS FOR MariaDB ###\n"
                    echo "Enter current password for root (enter for none): Just press the Enter"
                    echo "Set root password? [Y/n]: Y"
                    echo "New password: Enter password\n"
                    echo "Re-enter new password: Repeat password"
                    echo "Remove anonymous users? [Y/n]: Y"
                    echo "Disallow root login remotely? [Y/n]: Y"
                    echo "Remove test database and access to it? [Y/n]: Y"
                    printf "Reload privilege tables now? [Y/n]: Y\n"
                    eval $command
                fi
                printf "\n\n" 
                index=$index+1              
            done

            queries=("USE mysql;" "UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='$userDatabase';" "FLUSH PRIVILEGES;")
            if [ "$database_selected" = "1" ]; then
                commandDatabase="sudo mysql -u $userDatabase"
            else
                commandDatabase="sudo mariadb -u $userDatabase"
            fi
            for query in "${queries[@]}"; do
                $commandDatabase -p -e "$query"
            done

            if [ "$database_selected" = "1" ]; then
                sudo service mysql restart
            else
                sudo service mariadb restart
            fi
        fi
    fi
            
}

# Grant All Access on database selected
function grantAccessDatabase () {
    local option="$(getDataBase)"
    case "$option" in
        1|2) # MySQL | MariaDb
            local bindAddressStr="bind-address"
            local addressStr="127.0.0.1"
            local addressStrReplace="0.0.0.0"
            local db_name=""
            local username="root"
            local password=""
            local address="%"
            local commandDb=""
            local queryDb

            # Get db name
            read -p "Insert database name(ENTER TO CANCEL): " db_name
            if [ -n "$db_name" ]; then
                if [ "$option" = "1" ]; then # MySQL
                    _file="/etc/mysql/mysql.conf.d/mysql.cnf"
                    commandDb="mysql"
                else # MariaDb
                    _file="/etc/mysql/mariadb.conf.d/50-server.cnf"
                    commandDb="mariadb"
                fi

                # Get username
                read -p "Insert username(PRESS ENTER TO Default: root): " db_info
                if [ -n "$db_info" ]; then
                    username="$db_info"
                fi
                commandDb="$commandDb -u $username"

                # Get password
                read -sp "Insert password(PRESS ENTER TO CONTINUE): " password
                if [ -n "$password" ]; then
                    commandDb="$commandDb -p$password"
                fi

                # Get address
                db_info=""
                printf "\n\nINFO Address Insertion:\n"
                echo "% - All IP"
                echo "1.1.% - Only IP init with 1.1."
                echo "1.1.1.1 - Only IP 1.1.1.1"
                read -p "Insert IP Address(PRESS ENTER TO Default: All IP): " db_info
                if [ -n "$db_info" ]; then
                    address="$db_info"
                fi

                # Replace bind-address
                echo "Replace bind-address..."
                lineNumber="$(cat "$_file" | grep -n "$bindAddressStr" | grep "$addressStr" | cut -d ":" -f1)"
                sedArgs="s/$addressStr/$addressStrReplace/"
                sudo sed -i "$lineNumber$sedArgs" "$_file"

                echo "Restart database service..."
                if [ "$option" = "1" ]; then # MySQL
                    sudo systemctl restart mysql.service
                else # MariaDb
                    sudo systemctl restart mariadb.service
                fi

                echo "Execute query to grant access to IP Address..."
                queryDb="\"GRANT ALL ON $db_name.* TO '$username'@'$address' IDENTIFIED BY '$password';\""
                echo "$queryDb"
                eval "$commandDb -e $queryDb"

                # Print Help
                printf "\n\nTo check execute\n"
                printf "\t- sudo netstat -anp | grep 3306\n\n"
                printf "To connect to the server from the IP execute\n"
                printf "\t- sudo mysql -u USERNAME -pDATABASE_USER_PASSWORD -h server_hostname_or_IP_address\n\n"
                printf "You may want to open Ubuntu Firewall to allow IP address to connect on port 3306.\n"
                printf "\t- sudo ufw allow from ip_address to any port 3306\n\n"
            fi
        ;;
    esac
    
}

function databaseTools () {
    # Execute
    while [ 1 ]; do
        echo "##########################"
        echo "Selected Tool: ${nameProjectArray[4]}"
        # Print Menu
        echo
        echo "0 - Clear Screen"
        echo "------"
        echo "1 - Grant All Access"
        echo "------"
        echo "Back, PRESS ENTER"
        read -p "Insert an option: " option
        
        case "$option" in
            0) # Clear Screen
                clearScreen
            ;;
            1) # Grant All Access
                grantAccessDatabase
            ;;
            *) # Back
                break
            ;;
        esac
        printf "\n\n"
    done
}

################################################
# Web Server Tools
################################################
declare phpVersion=""
if [ `command -v php` ]; then
    phpVersion=$(php -v | grep -i php | cut -d ' ' -f2 | cut -d '.' -f1-2 | head -1)
fi

function printEnabledProjectsWebServer () {
    local virtual_conf="$1"
    local port="$2"
    printf "FILE/PROJECT: $virtual_conf --- PORT: $port\n"
}

function getWebServer () {
    echo "Selection of Web Server" >&2
    echo "1 - Apache2" >&2
    echo "2 - NGinx" >&2
    echo "ENTER TO CANCEL" >&2
    read -p "Insert an option: " option
    echo "$option"
}

function getTecnology () {
    echo "Selection of Tecnology" >&2
    echo "1 - PHP" >&2
    echo "ENTER TO CANCEL" >&2
    read -p "Insert an option: " option
    echo "$option"
}

function installDependencyWebServer () {
    local webserver_selected="$(getWebServer)"
    local -a webserver_commands
    local -i index="0"
    local name_webserver

    echo "Dependency Web Server. Will be execute/install..."

    if [ "$webserver_selected" = "1" ]; then
        # Define
        name_webserver="Apache2"
        webserver_commands=("apache2")        
        printf "\n$name_webserver:\n"
        for webserverCmd in "${webserver_commands[@]}"; do
            printf "\t- sudo apt install $webserverCmd\n"
        done
    elif [ "$webserver_selected" = "2" ]; then
        # Define
        name_webserver="NGinx"
        webserver_commands=("nginx")        
        printf "\n$name_webserver:\n"
        for webserverCmd in "${webserver_commands[@]}"; do
            printf "\t- sudo apt install $webserverCmd\n"
        done
    fi

    read -p "Continue? [y/n]: " isContinue
    if [ "$isContinue" = "y" ]; then 
        printf "\nInstalling $name_database...\n"
        for command in "${webserver_commands[@]}"; do
            echo "Execute: sudo apt install $command"
            sudo apt install $command
            printf "\n\n"            
        done
    fi
}

function configWebServer () {
    local webserver_selected="$(getWebServer)"
    local tecnology_selected

    if [ -n "$webserver_selected" ]; then
        tecnology_selected="$(getTecnology)"

        # Apache2
        if [ "$webserver_selected" = "1" ]; then
            # Enable mod rewrite
            sudo a2enmod rewrite
            sudo service apache2 restart

            # Disable mod mpm_event
            sudo a2dismod mpm_event
            sudo service apache2 restart

            if [ "$tecnology_selected" = "1" ]; then
                # Enable mod php
                sudo a2enmod php$phpVersion
                sudo service apache2 restart
            fi

            # Reload and Restart
            sudo service apache2 reload
            sudo service apache2 restart

        # NGinx
        elif [ "$webserver_selected" = "2" ]; then
            sudo service nginx start
            sudo service nginx reload
            sudo service nginx restart
        fi
    fi
}

function enableWebProject () {
    local webserver_selected="$(getWebServer)"
    local path_default="$(echo $PWD)"

    if [ -n "$webserver_selected" ]; then

        # Get path
        printf "\nPress ENTER to default: $path_default\n"
        read -p "Insert full path of web root path project: " new_path_project
        if [ ! -z "$new_path_project" ]&&[ -d "$new_path_project" ]; then
            path_default="$new_path_project"
        fi
        
        # Get port
        read -p "Insert port for project( PRESS ENTER TO CANCEL ): " port_project

        # Get name of project
        read -p "Insert name of project(Whitout space): " name_project

        if [ -n "$port_project" ]&&[ -n "$name_project" ]; then
            printf "\nInfo inserted:\n"
            echo "Web Root Path: $path_default"
            echo "PORT: $port_project"
            echo "Name Project: $name_project"
            read -p "Continue?[y/N]: " is_continue
            echo ""

            if [ "$is_continue" = "y" ]; then
                is_continue=""

                # Apache
                if [ "$webserver_selected" = "1" ]; then
                    local group="$(ps aux | egrep '([a|A]pache|[h|H]ttpd)' | awk '{ print $1}' | uniq | tail -1)"
                    local path_apache="/etc/apache2"
                    local sites_available_path="$path_apache/sites-available"
                    local port_apache_file="$path_apache/ports.conf"
                    local line_number_of_first_listen="$(grep -wn "Listen 80" /etc/apache2/ports.conf | cut -f1 -d':')"
                    local is_port_exist="$(cat "$port_apache_file" | grep -w "Listen $port_project")"
                    local template_apache="$filesTemplatePath/virtualConfApacheTemplate.conf"
                    local file_virtual_project="$sites_available_path/$name_project.conf"

                    # Check if port exist
                    if [ -n "$is_port_exist" ]; then
                        echo "Probably already any project using port $port_project"
                        read -p "Continue?[y/N]: " is_continue
                    else
                        is_continue="y"
                    fi
                    
                    if [ "$is_continue" = "y" ]; then
                        echo "Copy Template..."
                        sudo cp "$template_apache" "$file_virtual_project"

                        echo "Set PORT..."
                        sudo sed -i "s/PORTO/$port_project/" "$file_virtual_project"
                        sudo sed -i "$line_number_of_first_listen a\Listen $port_project" "$port_apache_file"

                        echo "Set PATH..."
                        sudo sed -i "s#FULL_PATH_PROJECT#$path_default#" "$file_virtual_project"

                        echo "Enable Site..."
                        sudo a2ensite "$name_project.conf"

                        echo "Restart Apache"
                        sudo service apache2 restart

                        # Info
                        echo "Considering set group and permission on ROOT Project with this command if necessary:"
                        printf "\t- sudo chown -R :$group ROOT_PROJECT\n"
                        printf "\t- sudo chmod -R 755 ROOT_PROJECT\n\n"
                    fi

                # NGinx
                elif [ "$webserver_selected" = "2" ]; then
                    local group="$(ps aux | egrep '([a|A]pache|[h|H]ttpd)' | awk '{ print $1}' | uniq | tail -1)"
                    local path_nginx="/etc/nginx"
                    local sites_available_path="$path_nginx/sites-available"
                    local sites_enabled_path="$path_nginx/sites-enabled"
                    local is_port_exist="$(sudo lsof -i -n | grep nginx | awk '{print $9}' | cut -d ':' -f2 | grep -c "$port_project" | awk '!NF || !seen[$0]++')"
                    local template_nginx="$filesTemplatePath/virtualConfNginxTemplate"
                    local file_virtual_project="$sites_available_path/$name_project"

                    # Check if port exist                
                    if [ -n "$is_port_exist" ]&&[ "$is_port_exist" != 0 ]; then
                        echo "Probably already any project using port $port_project"
                        read -p "Continue?[y/N]: " is_continue
                    else
                        is_continue="y"
                    fi
                    
                    if [ "$is_continue" = "y" ]; then                        
                        echo "Copy Template..."
                        sudo cp "$template_nginx" "$file_virtual_project"

                        echo "Set PORT..."
                        sudo sed -i "s/PORTO/$port_project/" "$file_virtual_project"

                        echo "Set PATH..."
                        sudo sed -i "s#FULL_PATH_PROJECT#$path_default#" "$file_virtual_project"

                        echo "Set PHP Version..."
                        sudo sed -i "s#PHPVERSION#$phpVersion#" "$file_virtual_project"

                        echo "Set web site..."
                        sudo ln -s "$file_virtual_project" "$sites_enabled_path"

                        echo "Restart NGinx"
                        sudo service nginx restart

                        # Info
                        echo "Considering set group and permission on ROOT Project with this command if necessary:"
                        printf "\t- sudo chown -R :$group ROOT_PROJECT\n"
                        printf "\t- sudo chmod -R 755 ROOT_PROJECT\n\n"
                    fi
                fi
            fi
        fi
    fi   
}

function disableWebProject () {
    local webserver_selected="$(getWebServer)"
    local path_default="$(echo $PWD)"

    # Get port
    read -p "Insert port for project( PRESS ENTER TO CANCEL ): " port_project

    # Get name of project
    read -p "Insert name of project(Whitout space): " name_project

    if [ -n "$port_project" ]&&[ -n "$name_project" ]; then
        printf "\nInfo inserted:\n"
        echo "PORT: $port_project"
        echo "Name Project: $name_project"
        read -p "Continue?[y/N]: " is_continue
        echo ""

        if [ "$is_continue" = "y" ]; then
            # Apache
            if [ "$webserver_selected" = "1" ]; then
                local path_apache="/etc/apache2"
                local sites_available_path="$path_apache/sites-available"
                local port_apache_file="$path_apache/ports.conf"
                local line_number_of_listen_port="$(grep -wn "Listen $port_project" /etc/apache2/ports.conf | cut -f1 -d':')"
                local file_virtual_project="$sites_available_path/$name_project.conf"

                echo "Disable Site..."
                sudo a2dissite "$name_project.conf"

                echo "Delete project virtual conf file..."
                if [ -f "$file_virtual_project" ]; then
                    sudo rm "$file_virtual_project"
                fi

                echo "Remove port..."
                if [ -n "$line_number_of_listen_port" ]; then
                    sudo sed -i "$line_number_of_listen_port d" "$port_apache_file"
                fi

                echo "Restart Apache"
                sudo service apache2 restart

            # NGinx
            elif [ "$webserver_selected" = "2" ]; then
                local path_nginx="/etc/nginx"
                local sites_available_path="$path_nginx/sites-available"
                local sites_enabled_path="$path_nginx/sites-enabled"
                local file_virtual_project="$sites_available_path/$name_project"

                echo "Delete project virtual conf file..."
                if [ -f "$file_virtual_project" ]; then
                    sudo rm "$file_virtual_project"
                    sudo rm "$sites_enabled_path/$name_project"
                fi

                echo "Restart NGinx"
                sudo service nginx restart
            fi
        fi
    fi
    printf "\n\n"
}

function getListEnabledWebProject () {
    local webserver_selected="$(getWebServer)"
    local -a ports
    local -a virtual_conf_files
    local -i isUsed="0"
    local -i isEmpty="0"

    printf "\nList of enabled projects...\n"

    # Apache
    if [ "$webserver_selected" = "1" ]; then
        ports=("$(cat /etc/apache2/ports.conf | grep -w "Listen" | head -n -2 | cut -f2 -d' ' | tr '\n' ' ')")
        virtual_conf_files=("$(ls /etc/apache2/sites-available/ | grep -v "000-default.conf" | grep -v "default-ssl.conf")")
        IFS=' ' read -ra ADDR_PORTS <<< "$ports"
        IFS=' ' read -ra ADDR_VIRTUAL_CONF_FILES <<< "$virtual_conf_files"
        printf "\n"
        for port in "${ADDR_PORTS[@]}"; do
            for virtual_conf in "${ADDR_VIRTUAL_CONF_FILES[@]}"; do
                isUsed="$(cat /etc/apache2/sites-available/$virtual_conf | grep -c "$port")"
                if [ $isUsed -gt 0 ]; then
                    isEmpty="1"
                    printEnabledProjectsWebServer "$virtual_conf" "$port"
                fi
            done
        done
    
    # NGinx
    elif [ "$webserver_selected" = "2" ]; then
        ports=("$(sudo lsof -i -n | grep nginx | awk '{print $9}' | cut -d ':' -f2 | awk '!NF || !seen[$0]++' | tr '\n' ' ')")
        virtual_conf_files=("$(ls /etc/nginx/sites-enabled/ | grep -v "default")")
        IFS=' ' read -ra ADDR_PORTS <<< "$ports"
        IFS=' ' read -ra ADDR_VIRTUAL_CONF_FILES <<< "$virtual_conf_files"
        printf "\n"
        for port in "${ADDR_PORTS[@]}"; do
            for virtual_conf in "${ADDR_VIRTUAL_CONF_FILES[@]}"; do
                isUsed="$(cat /etc/nginx/sites-enabled/$virtual_conf | grep -c "$port")"
                if [ $isUsed -gt 0 ]; then
                    isEmpty="1"
                    printEnabledProjectsWebServer "$virtual_conf" "$port"
                fi
            done
        done    
    fi

    if [ $isEmpty -eq 1 ]; then
        printf "\n\n"
    fi
}

function webserverTools () {
    # Execute
    while [ 1 ]; do
        echo "##########################"
        echo "Selected Tool: ${nameProjectArray[5]}"
        # Print Menu
        echo
        echo "0 - Clear Screen"
        echo "------"
        echo "1 - Config Web Server"
        echo "2 - Enable Project"
        echo "3 - Disable Project"
        echo "4 - List Enabled Project"
        echo "------"
        echo "Back, PRESS ENTER"
        read -p "Insert an option: " option
        
        case "$option" in
            0) # Clear Screen
                clearScreen
            ;;
            1) # Config Web Servers
                configWebServer
            ;;
            2) # Enable Projects
                enableWebProject
            ;;
            3) # Disable Project
                disableWebProject
            ;;
            4) # Get List of enabled projects
                getListEnabledWebProject
            ;;
            *) # Back
                break
            ;;
        esac
        printf "\n\n"
    done
}

################################################
# Network tools
################################################
declare -a all_ip_only
declare -a all_interface_only

function convertAllIpOrInterfaceToArray () {
    local stringToConvert="$1"
    local -i isIp="$2"
    
    # Convert ips and interfaces string to array
    if [ "$isIp" -eq "1" ]; then
        IFS=' ' read -r -a all_ip_only <<< "$stringToConvert"
    else
        IFS=' ' read -r -a all_interface_only <<< "$stringToConvert"
    fi
}

function getIpOnly () {
    local interface="$1"
    local all_ip="$(ip a show $interface | grep inet | awk -F' ' '{print $2}' | cut -d'/' -f1 | awk '{printf "%s" (NR%3==0?RS:FS),$1}')"
    echo "$all_ip"
}

function getAllInterfacesOnly () {
    local all_interfaces="$(ip -o link show | awk -F': ' '{print $2}' | awk '{ORS=" ";}; !NF{ORS="\n"};1')"
    echo "$all_interfaces"
}

function showAllIp () {
    local -i exist

    # Get info
    convertAllIpOrInterfaceToArray "$(getAllInterfacesOnly)" 0

    printf "\nList IPs...\n"

    for interface in "${all_interface_only[@]}"; do
        echo "INTERFACE: $interface"
        convertAllIpOrInterfaceToArray "$(getIpOnly "$interface")" 1
        for ip in "${all_ip_only[@]}"; do
            exist="$(ip -f inet addr show "$interface" | grep -wc "$ip")"
            if [ "$exist" -gt "0" ]; then
                printf "\t- IPv4: $ip\n"
            fi

            existSix="$(ip -f inet6 addr show "$interface" | grep -wc "$ip")"
            if [ "$existSix" -gt "0" ]; then
                printf "\t- IPv6: $ip\n"
            fi
            
        done
        printf "\n"
    done
}

function printListInterface () {
    # Get info
    convertAllIpOrInterfaceToArray "$(getAllInterfacesOnly)" 0

    printf "\nList INTERFACES...\n"
    for interface in "${all_interface_only[@]}"; do
        printf "\t- $interface\n"
    done
}


function upInterface () {
    local interface

    echo "$(printListInterface)"
    echo
    read -p "Insert interface(PRESS ENTER TO CANCEL): " interface

    if [ -n "$interface" ]; then
        sudo ip link set "$interface" up
    fi
}

function downInterface () {
    local interface

    echo "$(printListInterface)"
    echo
    read -p "Insert interface(PRESS ENTER TO CANCEL): " interface

    if [ -n "$interface" ]; then
        sudo ip link set "$interface" down
    fi
}

function deleteInterface () {
    local interface

    echo "$(printListInterface)"
    
    printf "\n\nWARNING: THIS ACTION NOT REVERSIBLE\n"
    read -p "Insert interface(PRESS ENTER TO CANCEL): " interface

    if [ -n "$interface" ]; then
        sudo ip link set "$interface" down
        sudo ip link delete "$interface"
    fi
}


function networkTools () {
    # Execute
    while [ 1 ]; do
        echo "##########################"
        echo "Selected Tool: ${nameProjectArray[6]}"
        # Print Menu
        echo
        echo "0 - Clear Screen"
        echo "------"
        echo "1 - Show All IP"
        echo "2 - UP INTERFACE"
        echo "3 - DOWN INTERFACE"
        echo "------"
        echo "4 - Delete INTERFACE"
        echo "------"
        echo "Back, PRESS ENTER"
        read -p "Insert an option: " option
        
        case "$option" in
            0) # Clear Screen
                clearScreen
            ;;
            1) # Show All IP
                showAllIp
            ;;
            2) # UP INTERFACE
                upInterface
            ;;
            3) # DOWN INTERFACE
                downInterface
            ;;
            4) # Delete INTERFACE
                deleteInterface
            ;;
            *) # Back
                break
            ;;
        esac
        printf "\n\n"
    done
}

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
