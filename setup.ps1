Write-Output "Beginning the set-up"

Get-ChildItem .\modules\*.psm1 | Import-Module -Force

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$chocopkgs = Get-ChocoPackages "chocopkg.txt"
Install-ChocoPackages $chocopkgs 0