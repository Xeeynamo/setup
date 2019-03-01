function Start-Setup {
    Write-Output "Beginning the set-up"

    Get-ChildItem .\modules\*.psm1 | Import-Module -Force

    $chocopkgs = Get-ChocoPackages "chocopkg.txt"
    Install-ChocoPackages $chocopkgs 1
    Install-ChocoPackages $chocopkgs 2
    Install-ChocoPackages $chocopkgs 3
}