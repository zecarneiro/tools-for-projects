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