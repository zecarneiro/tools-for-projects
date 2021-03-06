param(
    [ValidateSet("install","uninstall", "create-exec", IgnoreCase = $false)] # IgnoreCase set autocomplete
    [string]
    $INSTALLER,
    [switch]
    $RESET_JETBRAINS,
    [string]
    $JAVA_PATH = "",
    [string]
    $MAVEN_PATH = ""
)

#================================================
#                SYSTEM VARIABLES
#================================================
$CURRENT_DIRECTORY = "$PSScriptRoot"
#=========== END OF SYSTEM VARIABLES ============

#================================================
#                IMPORTS
#================================================
. "$CURRENT_DIRECTORY\generic.ps1"
. "$CURRENT_DIRECTORY\registry-manager.ps1"
#================ END OF IMPORTS ================

$projectName = "tools-for-projects"
$installDir = "$HOME\OtherApps\$projectName"

#================================================
#                INSTALL/UNINSTALL
#================================================
function Uninstall {
    if (!(CheckCommandExist("node"))) {
        Write-Error -Message "Please install NodeJS"
        exit(1)
    }
    if ((CheckCommandExist($projectName))) {
        InvokeCommand -program "npm" -argumentString "uninstall -g $projectName" -waitForExit
    }
    RemoveItem "$installDir"
    PrintMessage -message "Uninstall complete" "success"
}
function Install {
    if (!(CheckCommandExist("node"))) {
        Write-Error -Message "Please install NodeJS"
        exit(1)
    }
    Uninstall
    CreateItem "$installDir"
    Copy-Item -Path "*" -Destination "$installDir" -Recurse
    Set-Location "$installDir"
    InvokeCommand -program "npm" -argumentString "install -g ." -waitForExit -cwd "$installDir"
    Set-Location "$CURRENT_DIRECTORY"
    Set-Location ..\..
    PrintMessage -message "Install complete" "success"
}
#=========== END OF INSTALL/UNINSTALL ===========

function ResetJetbrains {
    $baseDir="${env:APPDATA}\JetBrains"
    $ideInfo = @{
        idea = @{
            path = "IntelliJIdea";
            regedit = "HKEY_CURRENT_USER\Software\JavaSoft\Prefs\jetbrains\idea"
        };
        rider = @{
            path = "Rider";
            regedit = ""
        };
        clion = @{
            path = "CLion";
            regedit = ""
        };
        pycharm = @{
            path = "PyCharm";
            regedit = ""
        }
    }
    $envDir="eval"
    $optionsFile="options\other.xml"
    $ideInfo.GetEnumerator() | ForEach-Object {
        $allDir=(Get-ChildItem -Path "$baseDir" -Directory -Recurse -Filter "$($_.Value.path + '*')")
        $regeditPath = "$($_.Value.regedit)"
        For ($j=0; $j -lt $allDir.Length; $j++) {
            $directoryEval = ("$baseDir\" + $allDir[$j] + "\$envDir")
            $otherFile = ("$baseDir\" + $allDir[$j] + "\$optionsFile") 
            if ((ItemExist "$directoryEval") -or (ItemExist "$otherFile") -or (ItemExist "$regeditPath" -isRegedit)) {
                PrintMessage -message ("Reset " + $allDir[$j]) "none"
                RemoveItem "$directoryEval"
                RemoveItem "$otherFile"
                RemoveItem "$regeditPath" -isRegedit
            }
        }
    }
    PrintMessage -message "Done" "success"
}
function InstallUninstallJava() {
    $path = (GetEnvVariable -type "system" -name "Path")
    $javaHomeEnvKey = "JAVA_HOME"
    $isSet = $false

    # Remove old
    $oldJava = "$env:JAVA_HOME"
    if ($oldJava.Length -gt 0) {
        PrintMessage -message "Uninstall: $oldJava" "none"
        $path = $path.replace(";$oldJava\bin", "")
        SetEnvVariable -type "system" -name "Path" -value "$path"
        DeleteEnvVariable -type "system" -name "$javaHomeEnvKey"
        $isSet = $true
    }

    if (($JAVA_PATH.Length -gt 0) -and ($JAVA_PATH -ne "-u")) {
        PrintMessage -message "Install: $JAVA_PATH" "none"
        SetEnvVariable -type "system" -name "$javaHomeEnvKey" -value "$JAVA_PATH"
        SetEnvVariable -type "system" -name "Path" -value "$($path + ";$JAVA_PATH\bin")"
        $isSet = $true
    }

    if ($isSet) {
        Stop-Process -ProcessName explorer
    }
}
function InstallUninstallMaven() {
    $path = (GetEnvVariable -type "system" -name "Path")
    $mavenHomeEnvKey = "MAVEN_HOME"
    $isSet = $false

    # Remove old
    $oldMaven = "$env:MAVEN_HOME"
    if ($oldMaven.Length -gt 0) {
        PrintMessage -message "Uninstall: $oldMaven" "none"
        $path = $path.replace(";$oldMaven\bin", "")
        SetEnvVariable -type "system" -name "Path" -value "$path"
        DeleteEnvVariable -type "system" -name "$mavenHomeEnvKey"
        $isSet = $true
    }

    if (($MAVEN_PATH.Length -gt 0) -and ($MAVEN_PATH -ne "-u")) {
        PrintMessage -message "Install: $MAVEN_PATH" "none"
        SetEnvVariable -type "system" -name "$mavenHomeEnvKey" -value "$MAVEN_PATH"
        SetEnvVariable -type "system" -name "Path" -value "$($path + ";$MAVEN_PATH\bin")"
        $isSet = $true
    }

    if ($isSet) {
        RestartExplorer
    }
}

#================================================
#                MAIN
#================================================
function Main {
    if ($INSTALLER -eq "install") {
        Install
    } elseif ($INSTALLER -eq "uninstall") {
        Uninstall
    } elseif ($INSTALLER -eq "create-exec") {
        InvokeCommand -program "npm" -argumentString "install" -waitForExit -cwd "$(GetDir -type "pwd")"
        InvokeCommand -program "npm" -argumentString "run compile" -waitForExit -cwd "$(GetDir -type "pwd")"
        CompressItems -files @("bin", "files", "node_modules", "scripts", "package-lock.json", "package.json", "tsconfig.json") -dest $projectName
    }
    if ($RESET_JETBRAINS) { ResetJetbrains }
    if ($JAVA_PATH.Length -gt 0) {
        InstallUninstallJava
        WaitForUserInputToConitnue
    }
    if ($MAVEN_PATH.Length -gt 0) {
        InstallUninstallMaven
        WaitForUserInputToConitnue
    }
}
Main