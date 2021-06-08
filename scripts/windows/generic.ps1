function SetEnvVariable() {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("local", "system", IgnoreCase = $false)] # IgnoreCase set autocomplete
        [string] $type,
        [string] $name = $(throw "Please specify a property name"),
        [string] $value
    )
    $path = $null
    if ((CompareString -first "$type" -second "local")) {
        $path = $REGISTRY_PATH_PREFIX["HKEY_CURRENT_USER"] + "Environment"
    } elseif ((CompareString -first "$type" -second "system")) {
        $path = $REGISTRY_PATH_PREFIX["HKEY_LOCAL_MACHINE"] + "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    }
    if ((Test-RegistryValue -path "$path" -name "$name")) {
        UpdateProperty -path "$path" -name "$name" -value "$value"
    } else {
        AddProperty -path "$path" -name "$name" -value "$value"
    }
}
function GetEnvVariable() {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("local", "system", IgnoreCase = $false)] # IgnoreCase set autocomplete
        [string] $type,
        [string] $name = $(throw "Please specify a property name")
    )
    $path = $null
    if ((CompareString -first "$type" -second "local")) {
        $path = $REGISTRY_PATH_PREFIX["HKEY_CURRENT_USER"] + "Environment"
    } elseif ((CompareString -first "$type" -second "system")) {
        $path = $REGISTRY_PATH_PREFIX["HKEY_LOCAL_MACHINE"] + "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    }
    if ((Test-RegistryValue -path "$path" -name "$name")) {
        return (GetProperty -path "$path" -name "$name")
    }
    return $null
}
function DeleteEnvVariable() {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("local", "system", IgnoreCase = $false)] # IgnoreCase set autocomplete
        [string] $type,
        [string] $name = $(throw "Please specify a property name")
    )
    $path = $null
    if ((CompareString -first "$type" -second "local")) {
        $path = $REGISTRY_PATH_PREFIX["HKEY_CURRENT_USER"] + "Environment"
    } elseif ((CompareString -first "$type" -second "system")) {
        $path = $REGISTRY_PATH_PREFIX["HKEY_LOCAL_MACHINE"] + "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    }
    if ((Test-RegistryValue -path "$path" -name "$name")) {
        DeleteProperty -path "$path" -name "$name"
    }
}

function CompareString() {
    param(
        [string] $first,
        [string] $second,
        [switch] $caseSensitive
    )
    if ($caseSensitive) {
        return "$first" -ceq "$second"
    }
    return "$first" -ieq "$second"
}
function ArrayMergeNoDuplicatedValue() {
    param(
        $first,
        $second
    )
    return ($first + $second) | Select-Object -Unique -Property Name
}
function ObjectMergeNoDuplicatedValue() {
    param(
        $first,
        $second,
        [string] $property
    )
    return ($first + $second) | Select-Object -Unique -Property $property
}
function WaitForUserInputToConitnue {
    Write-Host -NoNewLine "`nPress any key to continue...";
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
    PrintMessage -message "`nExecute >> COMMAND: `"$program $argumentString`", CWD: `"$cwd`"" "info"
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