#!/bin/bash
# José M. C. Noronha

# Global
declare nameProjectArray=("Angular" "CakePHP" "Docker" "DataBases")
declare currentPath="$(echo $PWD)"
declare pid
declare isKillPID="0"

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
    echo "Installing NodeJS..."
    local -a node_commands=("sudo chown -R $USER /usr/local" "sudo chown -R $USER /usr/local")
    node_commands+=("sudo chown -R $USER:$(id -gn $USER) $HOME/.config" "sudo snap install node --channel=10/stable --classic")
    for command in "${node_commands[@]}"; do
        echo "Execute: $command"
        eval $command
    done
    echo

    echo "Installing Angular..."
    local -a angular_commands=("echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p")
    angular_commands+=("sudo npm install -g @angular/cli")
    for command in "${angular_commands[@]}"; do
        echo "Execute: $command"
        eval $command
    done
}

# Necessary operation for angular
function angularTools () {
    # Clear Screen
    clearScreen

    while [ 1 ]; do
        setResetIsKillPID 0
        printMessage "${nameProjectArray[0]}"
        echo
        echo "0 - Install Dependencies"
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
        echo "10 - Back"
        echo "Exit, PRESS ENTER"
        read -p "Insert an option: " option

        # Clear Screen
        if [ -n "$option" ]; then
            clearScreen
        fi

        case "$option" in
            0) # Install Dependencies
                installDependencyAngular
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
            10) # Back
                break
            ;;
            *) # Exit
                exitMethod
            ;;
        esac
        printf "\n\n\n"
    done
}

################################################
# CakePHP Projects
################################################
function installDependencyCake () {
    echo "Installing Curl..."
    echo "Execute: sudo apt install curl"
    sudo apt install curl -y
    echo "Execute: curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer"
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer

    echo "Installing PHP..."
    local -a php_commands=("snmp-mibs-downloader" "php" "libapache2-mod-php" "php-mysql" "php-intl" "php-mbstring")
    php_commands+=("php-xml" "php-curl" "php-gd" "php-pear" "php-imagick" "php-imap" "php-memcache" "php-pspell" "php-recode")
    php_commands+=("php-snmp" "php-tidy" "php-xmlrpc" "php-sqlite3" "php-fpm")
    for command in "${php_commands[@]}"; do
        echo "Execute: sudo apt install $command"
        sudo apt install $command -y
    done
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
    local cake_bash_completion_directory="/opt/tools_for_projects/files/"

    # Install bash completion
    sudo apt install bash-completion -y

    # Install script
    if [ -d "$cake_bash_completion_directory" ]; then
        if [ -f "$_file_cake_script" ]; then
            sudo cp "$cake_bash_completion_directory" "$_file_cake_script"
        else
            echo "Error on set bash cake complete"
        fi
    else
        echo "Error on set bash cake complete"
    fi
}

# Necessary operation for cakephp
function cakePhpTools () {
    local command="bin/cake bake"

    # Clear Screen
    clearScreen

    # Execute
    while [ 1 ]; do
        setResetIsKillPID 0
        printMessage "${nameProjectArray[1]}"
        echo
        echo "0 - Install Dependencies"
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
        echo "17 - Back"
        echo "Exit, PRESS ENTER"
        read -p "Insert an option: " option
        
        # Clear Screen
        if [ -n "$option" ]; then
            clearScreen
        fi

        case "$option" in
            0) # Install Dependencies
                installDependencyCake
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
            17) # Back
                break
            ;;
            *) # Exit
                exitMethod
            ;;
        esac
        printf "\n\n\n"
    done
}

################################################
# Docker Tools
################################################
function installDependencyDocker () {
    echo "Installing Curl..."
    echo "Execute: sudo apt install curl"
    sudo apt install curl -y

    echo "Installing Docker..."
    # Part 1
    local -a docker_commands=("curl -sSL https://get.docker.com | sh" "sudo usermod -aG docker $USER")
    for command in "${docker_commands[@]}"; do
        echo "Execute: $command"
        eval $command
    done

    # Part 2
    docker_commands=("docker-ce-cli" "containerd.io" "docker-compose" "docker-containerd")
    for command in "${docker_commands[@]}"; do
        echo "Execute: sudo apt install $command"
        sudo apt install $command -y
    done

    echo "Init Docker service..."
    ./etc/init.d/docker start
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

function dockerTools () {
    # Clear Screen
    clearScreen

    while [ 1 ]; do
        printMessage "${nameProjectArray[2]}"
        echo
        echo "0 - Install Dependencies"
        echo "------"
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
        echo "10 - Show IP Address of container"
        echo "----------"
        echo "11 - Back"
        echo "Exit, PRESS ENTER"
        read -p "Insert a option: "  optionInsertedByUser

        if [ -n "$optionInsertedByUser" ]; then
            clearScreen
        fi

        # Execute user option
        case "$optionInsertedByUser" in
            0) # Install Dependencies
                installDependencyDocker
            ;;
            1) # Build
                echo "Build..."
                docker-compose build
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
            10) # Show Ip Address
                showIpAddressContainer
            ;;
            11) # Back
                break
            ;;
            *) # Exit
                exitMethod
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
    local -a database_command

    if [ "$database_selected" = "1" ]||[ "$database_selected" = "2" ]; then
        if [ "$database_selected" = "1" ]; then
            echo "Installing MySQL..."
            database_command=("mysql-server" "mysql-client")
        else
            echo "Installing MariaDb..."
            database_command=("mariadb-server" "mariadb-client")
        fi

        for command in "${database_command[@]}"; do
            echo "Execute: sudo apt install $command"
            sudo apt install $command -y
        done
        
        printf "\n### CONFIG OPTIONS FOR MariaDB ###\n"
		echo "Enter current password for root (enter for none): Just press the Enter"
		echo "Set root password? [Y/n]: Y"
		echo "New password: Enter password\n"
		echo "Re-enter new password: Repeat password"
		echo "Remove anonymous users? [Y/n]: Y"
		echo "Disallow root login remotely? [Y/n]: Y"
		echo "Remove test database and access to it? [Y/n]: Y"
		printf "Reload privilege tables now? [Y/n]: Y\n"
        sudo mysql_secure_installation
    fi
}

# Grant All Access on database selected
function grantAccessDatabase () {
    case "$(getDataBase)" in
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
    # Clear Screen
    clearScreen

    # Execute
    while [ 1 ]; do
        echo "##########################"
        echo "Selected Tool: ${nameProjectArray[3]}"
        # Print Menu
        echo
        echo "0 - Install Dependencies"
        echo "------"
        echo "1 - Grant All Access"
        echo "------"
        echo "2 - Back"
        echo "Exit, PRESS ENTER"
        read -p "Insert an option: " option

        if [ -n "$option" ]; then
            clearScreen
        fi
        
        case "$option" in
            0) # Install Dependencies
                installDependencyDatabases
            ;;
            1) # Grant All Access
                grantAccessDatabase
            ;;
            2) # Back
                break
            ;;
            *) # Exit
                exitMethod
            ;;
        esac
    done
}

################################################
# SSH Tools
################################################
function installDependencySSH () {
    local database_selected="$(getDataBase)"
    local -a ssh_command=("ssh" "xserver-xephyr")

    if [ "$database_selected" = "1" ]||[ "$database_selected" = "2" ]; then
        if [ "$database_selected" = "1" ]; then
            echo "Installing MySQL..."
            database_command=("mysql-server" "mysql-client")
        else
            echo "Installing MariaDb..."
            database_command=("mariadb-server" "mariadb-client")
        fi

        for command in "${database_command[@]}"; do
            echo "Execute: sudo apt install $command"
            sudo apt install $command -y
        done
        
        printf "\n### CONFIG OPTIONS FOR MariaDB ###\n"
		echo "Enter current password for root (enter for none): Just press the Enter"
		echo "Set root password? [Y/n]: Y"
		echo "New password: Enter password\n"
		echo "Re-enter new password: Repeat password"
		echo "Remove anonymous users? [Y/n]: Y"
		echo "Disallow root login remotely? [Y/n]: Y"
		echo "Remove test database and access to it? [Y/n]: Y"
		printf "Reload privilege tables now? [Y/n]: Y\n"
        sudo mysql_secure_installation
    fi
}

################################################
# Main and Help
################################################
# Main
function main () {
    while [ 1 ]; do
        # Clear Screen
        clearScreen

        # Print Menu
        echo "Tools necessary for projects"
        echo "1 - Angular"
        echo "2 - CakePHP"
        echo "3 - Docker"
        echo "4 - Databases"
        echo "Exit, PRESS ENTER"
        read -p "Insert an option: " option

        case "$option" in
            1) # Angular
                angularTools
            ;;
            2) # CakePHP
                cakePhpTools
            ;;
            3) # Docker
                dockerTools
            ;;
            4) # Databases
                databaseTools
            ;;
            *) # Exit
                break
            ;;
        esac
    done
}
main
