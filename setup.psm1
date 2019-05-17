Get-ChildItem .\modules\*.psm1 | Import-Module -Force

function Start-Setup {
    Write-Output "Beginning the set-up"

    $global:setupPath = (Get-Location).Path

    Install-UserProfile
    Install-StartLayout "./configs/start-layout.xml"
    Install-WindowsDeveloperMode
    Set-HidePeopleOnTaskbar $true
    Set-ShowPeopleOnTaskbar $false
    Set-SmallButtonsOnTaskbar $true
    Set-MultiMonitorTaskbarMode "2"
    Set-DisableWindowsDefender $true
    Set-DarkTheme $true
    Set-OtherWindowsStuff
    Disable-AdministratorSecurityPrompt
    Disable-UselessServices
    Disable-EasyAccessKeyboard
    Set-FolderViewOptions
    Disable-AeroShaking
    Uninstall-StoreApps
    Install-Ubuntu

    @(
        "Printing-XPSServices-Features"
        "Printing-XPSServices-Features"
        "FaxServicesClientPackage"
    ) | ForEach-Object { Disable-WindowsOptionalFeature -FeatureName $_ -Online -NoRestart }

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

    Install-Foobar2000Plugins "./configs/foobar2000plugins.txt"

    Get-ChildItem .\modules\common.psm1 | Import-Module -Force
    Get-ChildItem .\modules\*.psm1 | Import-Module -Force
    $global:setupPath = (Get-Location).Path

    Invoke-TemporaryGitDownload "debloat" "https://github.com/W4RH4WK/Debloat-Windows-10" {
        & "./scripts/block-telemetry.ps1"
    }

    Install-VisualStudioProfessional (Join-VisualStudioConfigurations @(
        "./configs/visualstudio/core.vsconfig",
        "./configs/visualstudio/dotnet.vsconfig",
        "./configs/visualstudio/cplusplus.vsconfig"
    ))

    # Install Dracula theme for Visual Studio Code
    Get-DownloadTemporaryFile "dracula.vsix" "https://github.com/dracula/visual-studio-code/releases/download/v2.16.0/dracula.vsix" {
        & code "--install-extension" "dracula.vsix"
    }

    # Install Dracula theme and configs for Notepad++
    Get-DownloadFile "~\AppData\Roaming\Notepad++\themes\Dracula.xml" "https://raw.githubusercontent.com/dracula/notepad-plus-plus/master/Dracula.xml"
    Copy-Item ".\configs\notepadplusplus\config.xml" "~\AppData\Roaming\Notepad++\"

    # Install Dracula theme for all terminals
    Invoke-TemporaryZipDownload "colortool" "https://github.com/Microsoft/console/releases/download/1810.02002/ColorTool.zip" {
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

        $termColorsPath = Join-Path $global:setupPath "configs/Dracula-ColorTool.itermcolors"
        (& ./colortool "-d" "-b" "-x" $termColorsPath) | Out-Null
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