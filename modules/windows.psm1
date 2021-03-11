function Set-ShellFolders {
    $userDir = $global:userDir
    @(
        "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders",
        "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    ) | % {
        Write-Host "aaa"
        Write-Host $_
        Set-RegistryString $_ "Desktop" "${userDir}\Desktop"
        Set-RegistryString $_ "My Music" "${userDir}\Music"
        Set-RegistryString $_ "My Pictures" "${userDir}\Pictures"
        Set-RegistryString $_ "My Video" "${userDir}\Video"
        Set-RegistryString $_ "Personal" "${userDir}\Documents"
        Set-RegistryString $_ "{374DE290-123F-4565-9164-39C4925E467B}" "${userDir}\Downloads"
        Set-RegistryString $_ "{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}" "${userDir}\Downloads"
    }
}

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

function Install-Appx([string]$url, [string]$name) {
    Invoke-WebRequest -Uri $url -OutFile $name -UseBasicParsing
    Add-AppxPackage -Path .\$name
    Remove-Item -Path .\$name -Force
}

function Install-Ubuntu() {
    Install-WindowsFeature Microsoft-Windows-Subsystem-Linux
    Install-Appx("https://aka.ms/wslubuntu2004", "Ubuntu.appx")
}

function Uninstall-Ubuntu() {
    Uninstall-WindowsFeature Microsoft-Windows-Subsystem-Linux
    Get-AppxPackage -Name CanonicalGroupLimited.Ubuntu18.04onWindows | Remove-AppxPackage
}

function Install-WindowsTerminal() {
    Install-Appx("https://github.com/microsoft/terminal/releases/download/v1.6.10571.0/Microsoft.WindowsTerminal_1.6.10571.0_8wekyb3d8bbwe.msixbundle", "WindowsTerminal.msixbundle")
}

function Install-StartLayout([string]$fileName) {
    # Unfortunately the function above imports the layout only for the "Default user"
    Import-StartLayout -LayoutPath $fileName -MountPath $env:SystemDrive\
    
    # so we have to import it to the user manually.
    $layoutDestinationPath = Join-Path $env:LOCALAPPDATA "Microsoft/Windows/Shell"
    $dstFile = Join-Path $layoutDestinationPath "LayoutModification.xml"

    New-MakeDirectoryForce $layoutDestinationPath
    Copy-Item $fileName $dstFile -Force

    # This will reset the start menu
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" /va /f

    # Restart explorer to apply the changes
    Stop-Process -ProcessName "explorer"
}

function Set-RegistryValue([string]$path, [string]$key, $value) {
    reg add $path /t REG_DWORD /f /v $key /d $value
}

function Set-RegistryString([string]$path, [string]$key, $value) {
    reg add $path /t REG_SZ /f /v $key /d $value
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

function Set-ShowNewsWidget([bool]$enable) {
    Set-RegistryBool "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" $enable
    Set-RegistryBool "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" $enable
}

function Set-ShowSearchOnTaskbar([bool]$enable) {
    Set-RegistryBool "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" $enable
    Set-RegistryBool "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" $enable
    Set-RegistryBool "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCortanaButton" $enable
    Set-RegistryBool "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCortanaButton" $enable
}

function Set-ShowTaskOnTaskbar([bool]$enable) {
    Set-RegistryBool "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" $enable
    Set-RegistryBool "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" $enable
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
    Set-RegistryBool "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DisallowShaking " $value
    Set-RegistryBool "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DisallowShaking " $value
}

function Set-EnableLongPathsForWin32($value) {
    Set-RegistryBool "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\FileSystem" "LongPathsEnabled " $value
}

function Set-DisableAdvertisementsForConsumerEdition([bool]$enable) {
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "1"
}

function Disable-Telemetry() {
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" "0"
}

function Set-DisableWindowsDefender([bool]$enable) {
    # Disables Windows Defender. Also impacts third-party antivirus software and apps.
    # https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/security-malware-windows-defender-disableantispyware
    Set-RegistryValue "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender" "DisableAntiSpyware" "1"
    Set-RegistryValue "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender" "DisableRoutinelyTakingAction" "1"
    Set-RegistryValue "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableBehaviorMonitoring" "1"
    Set-RegistryValue "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableOnAccessProtection" "1"
    Set-RegistryValue "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableScanOnRealtimeEnable" "1"
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
    Set-RegistryValue "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" "1"
}

function Set-MicrosoftEdgePreload {
    Set-RegistryBool "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" "AllowPrelaunch" $enable
    Set-RegistryBool "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" "AllowTabPreloading" $enable
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

function Disable-IntelPowerThrottling {
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDs" "1"
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDsRetroactive" "1"
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyInstanceIDs" "1"
    Set-RegistryValue "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyInstanceIDsRetroactive" "0"
    
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" "1" "*INT3400"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" "2" "*INT3402"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" "3" "*INT3403"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" "4" "*INT3404"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" "5" "*INT3407"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" "6" "*INT3409"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" "7" "PCI\VEN_8086&DEV_1603&CC_1180"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" "8" "PCI\VEN_8086&DEV_1903&CC_1180"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" "9" "PCI\VEN_8086&DEV_8A03&CC_1180"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" "10" "PCI\VEN_8086&DEV_9C24&CC_1180"
    
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyInstanceIDs" "1" "ACPI\VEN_INT&DEV_3403"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyInstanceIDs" "2" "ACPI\INT3403"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyInstanceIDs" "3" "*INT3403"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyInstanceIDs" "4" "ACPI\VEN_INT&DEV_3400"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyInstanceIDs" "5" "ACPI\INT3400"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyInstanceIDs" "6" "*INT3400"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyInstanceIDs" "7" "PCI\VEN_8086&DEV_1903&SUBSYS_07BE1028&REV_05"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyInstanceIDs" "8" "PCI\VEN_8086&DEV_1903&SUBSYS_07BE1028"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyInstanceIDs" "9" "PCI\VEN_8086&DEV_1903&CC_118000"
    Set-RegistryString "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyInstanceIDs" "10" "PCI\VEN_8086&DEV_1903&CC_1180"
}