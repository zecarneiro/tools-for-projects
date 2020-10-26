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