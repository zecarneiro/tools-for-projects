param(
    [ValidateSet("install","uninstall", IgnoreCase = $false)] # IgnoreCase set autocomplete
    [string]
    $INSTALLER
)

$projectName = "tools-for-projects"
$installDir = "$HOME\OtherApps\$projectName"
$currentDir = "$PSScriptRoot"
$listUnnecessaryFiles = @(
    # Git and vscode
    ".git", ".gitignore", ".gitmodules", ".vscode", "utils\nodejs-utils\.git", "utils\nodejs-utils\.gitignore"
    "utils\nodejs-utils\src", "src"
)

function InvokeCommand() {
    param (
        [string]$program = $(throw "Please specify a program" ),
        [string]$argumentString = "",
        [switch]$waitForExit,
        [string]$cwd = ""
    )

    $psi = new-object "Diagnostics.ProcessStartInfo"
    $psi.FileName = $program 
    $psi.Arguments = $argumentString
    if ($cwd.Length -gt 0) {
        $psi.UseShellExecute = $true
        $psi.WorkingDirectory = $cwd
    }
    $proc = [Diagnostics.Process]::Start($psi)
    if ( $waitForExit ) {
        $proc.WaitForExit();
    }
}

function ItemExist {
    param (
        [string]$item,
        [switch]$isFile
    )
    
    if ($isFile) {
        return (Test-Path -Path $item -PathType Leaf)
    }
    return (Test-Path $item)
}

function RemoveItems {
    param ([String[]] $items)
    if ($items.Count -gt 0) {
        Foreach ($item in $items) {
            If((ItemExist "$item") -or (ItemExist "$item" -isFile)) {
                Remove-Item $item -Recurse -Force -ErrorAction Stop
            }
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
                Write-Host "The item [$item] has been created."
            }
            catch {
                throw $_.Exception.Message
            }
        } else {
            Write-Host "Cannot create [$item] because a item with that name already exists."
        }
    } else {
        Write-Host "Ivalid item given"
    }
}

function CheckCommandExist {
    param ([string]$command)
    return (where.exe "$command")
}

function Uninstall {
    if (!(CheckCommandExist("node"))) {
        Write-Error -Message "Please install NodeJS"
        exit(1)
    }
    if ((CheckCommandExist($projectName))) {
        InvokeCommand -program "npm" -argumentString "uninstall -g $projectName" -waitForExit
    }
    RemoveItems "$installDir"
    Write-Host "Uninstall complete"
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
    RemoveItems $listUnnecessaryFiles
    Set-Location "$currentDir"
    Set-Location ..
    Write-Host "Install complete"
}

function Main {
    if ($INSTALLER -eq "install") {
        Install
    } elseif ($INSTALLER -eq "uninstall") {
        Uninstall
    }
}
Main