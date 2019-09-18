function Install-WindowsFeature($feature) {
    $featureState = Get-WindowsOptionalFeature -Online -FeatureName $feature
    if ($feature -ne "Enabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart | Out-Null
    }
}

function Uninstall-WindowsFeature($feature) {
    $featureState = Get-WindowsOptionalFeature -Online -FeatureName $feature
    if ($feature -eq "Enabled") {
        Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart | Out-Null
    }
}

function Install-Ubuntu() {
    Install-WindowsFeature Microsoft-Windows-Subsystem-Linux
    Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile Ubuntu.appx -UseBasicParsing
    Add-AppxPackage -Path .\Ubuntu.appx
    Remove-Item -Path .\Ubuntu.appx -Force
}

function Uninstall-Ubuntu() {
    Uninstall-WindowsFeature Microsoft-Windows-Subsystem-Linux
    Get-AppxPackage -Name CanonicalGroupLimited.Ubuntu18.04onWindows | Remove-AppxPackage
}

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

function Remove-RegistryKey([string]$path, [string]$key) {
    Remove-ItemProperty -Path $path -Name $key -Force
}

function Remove-RegistryFolder([string]$path) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
    }
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

function Set-DisableLockScreen($value) {
    Set-RegistryBool "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreen " $value
}

function Set-DisableAeroShake($value) {
    Set-RegistryBool "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoWindowMinimizingShortcuts " $value
    Set-RegistryBool "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoWindowMinimizingShortcuts " $value
}

function Set-EnableLongPathsForWin32($value) {
    Set-RegistryBool "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\FileSystem" "LongPathsEnabled " $value
}

function Set-DisableWindowsDefender([bool]$enable) {
    # Disables Windows Defender. Also impacts third-party antivirus software and apps.
    # https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/security-malware-windows-defender-disableantispyware
    Set-RegistryValue "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender" "DisableAntiSpyware" "1"
}

function Set-DarkTheme([bool]$enable) {
    Set-RegistryBool "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" ($enable -eq -$false)
}

function Set-ColorTheme([string]$color) {
    Set-RegistryBool "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" !$enable
}

function Disable-AdministratorSecurityPrompt() {
    # This option SHOULD be used to disable the automatic detection of installation packages that require elevation to install.
    # https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-gpsb/c2b4efc5-2fe8-4dc9-95f7-2417b3d4cc6d
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableInstallerDetection" "0"

    # Disabling this policy disables secure desktop prompting. All credential or consent prompting will occur on the interactive user's desktop.
    # https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-gpsb/9ad50fd3-4d8d-4870-9f5b-978ce292b9d8
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "PromptOnSecureDesktop" "0"

    # This option allows the Consent Admin to perform an operation that requires elevation without consent or credentials.
    # https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-gpsb/341747f5-6b5d-4d30-85fc-fa1cc04038d4
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin" "0"
}

function Disable-BingSearchInStartMenu {
    Set-RegistryValue "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" "0"
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

function Remove-3dObjectsFolder {
    Remove-RegistryFolder "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    Remove-RegistryFolder "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
}
