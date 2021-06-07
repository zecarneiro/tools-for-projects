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