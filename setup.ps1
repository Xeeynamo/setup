Write-Output "Beginning the set-up"

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Get-Content 'chocopkg.txt' |
    ForEach-Object {
        & choco install $_ -y
    }