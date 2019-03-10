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

    $chocopkgs = Get-ChocoPackages "chocopkg.txt"
    Install-ChocoPackages $chocopkgs 1
    Install-ChocoPackages $chocopkgs 2
    Install-ChocoPackages $chocopkgs 3

    Invoke-TemporaryGitDownload "debloat" "https://github.com/W4RH4WK/Debloat-Windows-10" {
        & ./scripts/block-telemetry.ps1
    }

    Install-VisualStudioProfessional "./configs/dev.vsconfig"

    # Install Dracula theme for Visual Studio Code
    Invoke-TemporaryGitDownload "darcula-vscode" "https://github.com/dracula/visual-studio-code.git" {
        & npm install
        & npm run build
    } "~/.vscode/extensions/theme-dracula"

    # Install Dracula theme for Notepad++
    Invoke-TemporaryGitDownload "darcula-notepadplusplus" "https://github.com/dracula/notepad-plus-plus.git" {
        New-MakeDirectoryForce "%AppData%\Notepad++\themes"
        Copy-Item "Dracula.xml" "%AppData%\Notepad++\themes"
    }

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