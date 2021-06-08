$REGISTRY_PATH_PREFIX = @{
    "HKEY_CURRENT_USER" = "HKCU:"
    "HKEY_CLASSES_ROOT" = "HKCR:"
    "HKEY_LOCAL_MACHINE" = "HKLM:"
}
function AddProperty {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $path,
        [string] $name,
        [string] $value
    )
    if ((Test-Path $path)) {
        if ($name) {
            PrintMessage -message "`nCreate Property: $path\$name with Value: $value" "none"
            New-ItemProperty -Path $path -Name $name -Value $value -Force | Out-Null
        } else {
            PrintMessage -message "`nInvalid $name" "error"
        }
    } else {
        PrintMessage -message "`nInvalid $path" "error"
    }    
}
function DeleteProperty {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $path,
        [string] $name
    )
    if ((ItemExist "$path")) {
        if ($name.Length -gt 0) {
            PrintMessage -message "`nDelete Property: $path\$name" "none"
            Remove-ItemProperty -Path "$path" -Name "$name" -Force -ErrorAction Stop
        } else {
            PrintMessage -message "`nDelete Property: $path" "none"
            Remove-ItemProperty -Path "$path" -Force -ErrorAction Stop
        }
    } else {
        PrintMessage -message "`nInvalid Path: $path" -type "error"
    }
}
function UpdateProperty() {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $path,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $name,
        $value
    )
    if ((ItemExist "$path")) {
        PrintMessage -message "`nUpdate Property: $path\$name with Value: $value" "none"
        Set-ItemProperty -Path "$path" -Name "$name" -Value "$value"
    } else {
        PrintMessage -message "`nInvalid Path: $path" -type "error"
    }
}
function GetProperty() {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $path,
        [string] $name
    )
    if ((ItemExist "$path")) {
        $data = (Get-ItemProperty -Path "$path")
        if ($name.Length -gt 0) {
            return $data.$name
        }
        return $data
    }
    return $null
}
function Test-RegistryValue {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $path,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $name
    )
    try {
        if ((GetProperty -path "$path").$name) {
            return $true
        }
        return $false
    } catch {
        return $false
    }
}