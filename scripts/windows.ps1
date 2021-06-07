param(
    [ValidateSet("install","uninstall", "create-exec", IgnoreCase = $false)] # IgnoreCase set autocomplete
    [string]
    $INSTALLER,
    [switch]
    $RESET_JETBRAINS,
    [string]
    $JAVA_PATH = ""
)

$projectName = "tools-for-projects"
$installDir = "$HOME\OtherApps\$projectName"
$currentDir = "$PSScriptRoot"
$listUnnecessaryFiles = @(
    # Git and vscode
    ".git", ".gitignore", ".gitmodules", ".vscode", "utils\nodejs-utils\.git", "utils\nodejs-utils\.gitignore"
    "utils\nodejs-utils\src", "src"
)

#================================================
#                FUNCTIONS UTILS
#================================================
function WaitForUserInputToConitnue {
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    Write-Host "`n"
}
function PrintMessage() {
    param(
        [ValidateSet("error","info", "warnning", "success", "none", IgnoreCase = $false)] # IgnoreCase set autocomplete
        [string]
        $type,
        [string]
        $message = ""
    )
    if ($type -eq "error") {
        Write-Host "$message" -ForegroundColor Red
    } elseif ($type -eq "info") {
        Write-Host "$message" -ForegroundColor Blue
    } elseif ($type -eq "warnning") {
        Write-Host "$message" -ForegroundColor Yellow
    } elseif ($type -eq "success") {
        Write-Host "$message" -ForegroundColor Green
    } else {
        Write-Host "$message"
    }
}
function InvokeCommand() {
    param (
        [string]$program = $(throw "Please specify a program" ),
        [string]$argumentString = "",
        [string]$cwd = ""
    )
    Write-Host "`nExecute >>" -ForegroundColor Red -BackgroundColor Yellow
    PrintMessage -message "`tCOMMAND: $program $argumentString `n`tCWD: $cwd" "info"
    if (($cwd.Length -gt 0) -and ($argumentString.Length -gt 0)) {
        Start-Process $program -ArgumentList $argumentString -WorkingDirectory $cwd -NoNewWindow -Wait
    } elseif (($cwd.Length -gt 0)) {
        Start-Process $program -WorkingDirectory $cwd -NoNewWindow -Wait
    } elseif (($argumentString.Length -gt 0)) {
        Start-Process $program -ArgumentList $argumentString -NoNewWindow -Wait
    } else {
        Start-Process $program -NoNewWindow -Wait
    }
}
function ItemExist {
    param (
        [string]$item,
        [switch]$isFile,
        [switch]$isRegedit
    )
    if ($item.Length -gt 0) {
        if ($isRegedit) {
            $item = "HKCU:\$item"
        }
        if ($isFile) {
            return (Test-Path -Path $item -PathType Leaf)
        }
        return (Test-Path $item)
    }
    return $false
}
function RemoveItem {
    param (
        [String]$item,
        [switch]$isRegedit
    )
    if ($item.Length -gt 0) {
        if ($isRegedit) {
            $item = "HKCU:\$item"
        }
        If((ItemExist "$item") -or (ItemExist "$item" -isFile)) {
            PrintMessage -message "Delete $item" "none"
            Remove-Item $item -Recurse -Force -ErrorAction Stop
        }
    }
}
function CreateItem {
    param (
        [string]$item,
        [switch]$isFile
    )
    if ($item) {
        if (($isFile -and -not(ItemExist "$item" -isFile)) -or -not(ItemExist "$item")) {
            try {
                if ($isFile) {
                    $null = New-Item -ItemType File -Path $item -Force -ErrorAction Stop
                } else {
                    $null = New-Item -ItemType Directory -Path "$item" -Force -ErrorAction Stop
                }
                PrintMessage -message "The item [$item] has been created." "success"
            }
            catch {
                throw $_.Exception.Message
            }
        } else {
            PrintMessage -message "Cannot create [$item] because a item with that name already exists." "info"
        }
    } else {
        PrintMessage -message "Ivalid item given" "error"
    }
}
function CheckCommandExist {
    param ([string]$command)
    if ((where.exe "$command")) {
        return $true
    }
    return $false
}
function CompressItems {
    param (
        [string[]]$files,
        [string]$dest = $(throw "Please specify a destination")
    )
    if ($files.Count -eq 0) {
        Compress-Archive -Path .\* -DestinationPath $dest -Force
    } else {
        Compress-Archive -LiteralPath $files -DestinationPath $dest -Force
    }
}
#============ END OF FUNCTIONS UTILS ============

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
    InvokeCommand -program "npm" -argumentString "install" -waitForExit -cwd "$installDir"
    InvokeCommand -program "npm" -argumentString "run compile" -waitForExit -cwd "$installDir"
    InvokeCommand -program "npm" -argumentString "install -g ." -waitForExit -cwd "$installDir"
    Foreach ($unnecessaryFile in $listUnnecessaryFiles) {
        RemoveItem $unnecessaryFile
    }
    Set-Location "$currentDir"
    Set-Location ..
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
    $sysenv = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    $path = (Get-ItemProperty -Path $sysenv -Name Path).Path
    $isSet = $false

    # Remove old
    $oldJava = "$env:JAVA_HOME"
    if ($oldJava.Length -gt 0) {
        PrintMessage -message "Uninstall: $oldJava" "none"
        $path = $path.replace(";$oldJava\bin", "")
        Set-ItemProperty -Path "$sysenv" -Name Path -Value "$path"
        Remove-ItemProperty -Path "$sysenv" -Name JAVA_HOME
        $isSet = $true
    }

    if (($JAVA_PATH.Length -gt 0) -and ($JAVA_PATH -ne "-u")) {
        PrintMessage -message "Install: $JAVA_PATH" "none"
        setx /m JAVA_HOME "$JAVA_PATH"
        $path = $path + ";$JAVA_PATH\bin"
        Set-ItemProperty -Path "$sysenv" -Name Path -Value "$path"
        $isSet = $true
    }

    if ($isSet) {
        Stop-Process -ProcessName explorer
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
        CompressItems -files @("files", "scripts", "src", "utils", "package-lock.json", "package.json", "tsconfig.json") -dest $projectName
    }
    if ($RESET_JETBRAINS) { ResetJetbrains }
    if ($JAVA_PATH.Length -gt 0) {
        InstallUninstallJava
        WaitForUserInputToConitnue
    }
}
Main