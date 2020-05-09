Get-ChildItem .\modules\*.psm1 | Import-Module -Force
$global:setupPath = (Get-Location).Path

function Start-Setup {
    Write-Output "Beginning the set-up"

    $global:setupPath = (Get-Location).Path

    # Make sure that Git Bash uses colors on Windows
    [System.Environment]::SetEnvironmentVariable("FORCE_COLOR", "true", "Machine")

    Install-UserProfile
    Install-StartLayout "./configs/start-layout.xml"
    Install-WindowsDeveloperMode
    Set-DisableAdvertisementsForConsumerEdition $true
    Disable-Telemetry
    Disable-IntelPowerThrottling
    Set-HidePeopleOnTaskbar $true
    Set-ShowPeopleOnTaskbar $false
    Set-SmallButtonsOnTaskbar $true
    Set-MultiMonitorTaskbarMode "2"
    Set-DisableWindowsDefender $true
    Set-DarkTheme $true
    Set-DisableLockScreen $true
    Set-DisableAeroShake $true
    Set-EnableLongPathsForWin32 $true
    Set-OtherWindowsStuff
    Remove-3dObjectsFolder
    Disable-AdministratorSecurityPrompt
    Disable-UselessServices
    Disable-EasyAccessKeyboard
    Set-FolderViewOptions
    Uninstall-StoreApps
    Install-Ubuntu

    # This will fail in Windows Sandbox
    @(
        "Printing-XPSServices-Features"
        "Printing-XPSServices-Features"
        "FaxServicesClientPackage"
    ) | ForEach-Object { Disable-WindowsOptionalFeature -FeatureName $_ -Online -NoRestart }

    # This will fail in Windows Sandbox
    @(
        "TelnetClient"
        "HypervisorPlatform"
        "NetFx3"
        "Microsoft-Hyper-V-All"
        "Containers-DisposableClientVM" # Windows Sandbox
    ) | ForEach-Object { Enable-WindowsOptionalFeature -FeatureName $_ -Online -NoRestart }

    $chocopkgs = Get-ChocoPackages "./configs/chocopkg.txt"
    Install-ChocoPackages $chocopkgs 1
    Install-ChocoPackages $chocopkgs 2
    Install-ChocoPackages $chocopkgs 3

    Remove-DesktopIcon
    Remove-HiddenAttribute "/ProgramData"
    Remove-HiddenAttribute (Join-Path $env:USERPROFILE "AppData")

    Install-Foobar2000Plugins "./configs/foobar2000plugins.txt"
    Install-VsCodeExtensions "./configs/vscode-extensions.txt"

    Get-ChildItem .\modules\common.psm1 | Import-Module -Force
    Get-ChildItem .\modules\*.psm1 | Import-Module -Force
    $global:setupPath = (Get-Location).Path

    Install-VisualStudioProfessional (Join-VisualStudioConfigurations @(
        "./configs/visualstudio/core.vsconfig",
        "./configs/visualstudio/dotnet.vsconfig",
        "./configs/visualstudio/cplusplus.vsconfig"
    ))


    # Install Dracula theme and configs for Notepad++
    Get-DownloadFile "~\AppData\Roaming\Notepad++\themes\Dracula.xml" "https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/Dracula.xml"
    Copy-Item ".\configs\notepadplusplus\config.xml" "~\AppData\Roaming\Notepad++\"

    # Install Dracula theme for all terminals
    Invoke-TemporaryZipDownload "colortool" "https://github.com/microsoft/terminal/releases/download/1904.29002/ColorTool.zip" {
        $termColorsPath = Join-Path $global:setupPath "configs/Dracula-ColorTool.itermcolors"
        (& ./colortool "-d" "-b" "-x" $termColorsPath)
        
        Set-PSReadlineOption -Color @{
            "Command" = [ConsoleColor]::Green
            "Parameter" = [ConsoleColor]::Gray
            "Operator" = [ConsoleColor]::Magenta
            "Variable" = [ConsoleColor]::White
            "String" = [ConsoleColor]::Yellow
            "Number" = [ConsoleColor]::Blue
            "Type" = [ConsoleColor]::Cyan
            "Comment" = [ConsoleColor]::DarkCyan
        }
    }

    Remove-TempDirectory
}

function Install-Foobar2000Plugins([string]$configFileName) {
    Get-Content $configFileName |
        Where-Object { $_[0] -ne '#' -and $_.Length -gt 0 } |
        ForEach-Object {
            Install-Foobar2000PluginFromUrl $_
        }
}
function Install-VsCodeExtensions([string]$configFileName) {
    Get-Content $configFileName |
        Where-Object { $_[0] -ne '#' -and $_.Length -gt 0 } |
        ForEach-Object {
            Install-VsCodeExtension $_
        }
}

function Remove-DesktopIcon() {
    Remove-Item -Path ((Join-Path $Env:USERPROFILE "Desktop") + "/*.lnk")
    Remove-Item -Path "/Users/Public/Desktop/*.lnk"
}

function Remove-HiddenAttribute([string]$path) {
    Set-ItemProperty $path -Name Attributes -Value Normal
}