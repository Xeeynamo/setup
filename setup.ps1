Write-Output "Beginning the set-up"

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Get-Content 'chocopkg.txt' |
    Where-Object { $_[0] -ne '#' -and $_.Length -gt 0} |
    ForEach-Object {
        & choco install $_ -y
    }