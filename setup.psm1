function Start-Setup {
    Write-Output "Beginning the set-up"

    Get-ChildItem .\modules\common.psm1 | Import-Module -Force
    Get-ChildItem .\modules\*.psm1 | Import-Module -Force

    Disable-UselessServices
    Uninstall-StoreApps
    Disable-EasyAccessKeyboard
    Set-FolderViewOptions
    Disable-AeroShaking

    $chocopkgs = Get-ChocoPackages "chocopkg.txt"
    Install-ChocoPackages $chocopkgs 1
    Install-ChocoPackages $chocopkgs 2
    Install-ChocoPackages $chocopkgs 3

    # Invoke-TemporaryZipDownload "colortool" "https://github.com/Microsoft/console/releases/download/1810.02002/ColorTool.zip" {
    #     & ./colortool "-d" "-b" "-x" "solarized_dark"
    # }

    Invoke-TemporaryGitDownload "debloat" "https://github.com/W4RH4WK/Debloat-Windows-10" {
        & ./scripts/block-telemetry.ps1
    }

    Install-VisualStudioProfessional "./configs/dev.vsconfig"

    Remove-TempDirectory
}