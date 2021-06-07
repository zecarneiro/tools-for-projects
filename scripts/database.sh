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