function Start-Setup {
    Write-Output "Beginning the set-up"

    Get-ChildItem .\modules\common.psm1 | Import-Module -Force
    Get-ChildItem .\modules\*.psm1 | Import-Module -Force
    $global:setupPath = (Get-Location).Path

    Disable-UselessServices
    Uninstall-StoreApps
    Disable-EasyAccessKeyboard
    Set-FolderViewOptions
    Disable-AeroShaking
    
    Install-StartLayout "./configs/start-layout.xml"

    $chocopkgs = Get-ChocoPackages "chocopkg.txt"
    Install-ChocoPackages $chocopkgs 1
    Install-ChocoPackages $chocopkgs 2
    Install-ChocoPackages $chocopkgs 3
    
    Get-ChildItem .\modules\common.psm1 | Import-Module -Force
    Get-ChildItem .\modules\*.psm1 | Import-Module -Force
    $global:setupPath = (Get-Location).Path

    Invoke-TemporaryGitDownload "debloat" "https://github.com/W4RH4WK/Debloat-Windows-10" {
        & ./scripts/block-telemetry.ps1
    }

    Install-VisualStudioProfessional "./configs/dev.vsconfig"

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