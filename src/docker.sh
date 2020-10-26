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