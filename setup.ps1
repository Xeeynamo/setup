Write-Output "Beginning the set-up"

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

@(
    "googlechrome"
) |
    ForEach-Object {
        & choco install $_ -y
    }