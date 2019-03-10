function Install-StartLayout([string]$fileName) {
    Import-StartLayout -LayoutPath $fileName -MountPath $env:SystemDrive\

    # This will reset the start menu
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" /va /f

    # Restart explorer to apply the changes
    Stop-Process -ProcessName "explorer"
}

function Set-RegistryValue([string]$path, [string]$key, $value) {
    reg add $path /t REG_DWORD /f /v $key /d $value
}

function Set-RegistryBool([string]$path, [string]$key, [bool]$enable) {
    $value = "0"
    if ($true -eq $enable) {
        $value = "1"
    }

    Set-RegistryValue $path $key $value
}

function Install-WindowsDeveloperMode {
    Set-RegistryBool "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense" $true
}

function Set-HidePeopleOnTaskbar([bool]$enable) {
    Set-RegistryBool "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer" "HidePeopleBar" $enable
    Set-RegistryBool "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer" "HidePeopleBar" $enable
}

function Set-ShowPeopleOnTaskbar([bool]$enable) {
    Set-RegistryBool "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" $enable
    Set-RegistryBool "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" $enable
}

function Set-SmallButtonsOnTaskbar([bool]$enable) {
    Set-RegistryBool "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSmallIcons " $enable
    Set-RegistryBool "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSmallIcons " $enable
}

function Set-MultiMonitorTaskbarMode($value) {
    Set-RegistryValue "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "MMTaskbarMode " $value
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "MMTaskbarMode " $value
}

function Set-OtherWindowsStuff {
    Set-RegistryValue "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "MMTaskbarGlomLevel" "1"
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "MMTaskbarGlomLevel" "1"
    Set-RegistryValue "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarGlomLevel" "1"
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarGlomLevel" "1"
    Set-RegistryValue "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSizeMove" "0"
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSizeMove" "0"
    Set-RegistryValue "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSuperHidden" "1"
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSuperHidden" "1"
}