function Get-TemporaryDownload([string]$uri) {
    $tmpFile = New-TemporaryFile
    Invoke-WebRequest -Uri $uri -OutFile $tmpFile.FullName

    return $tmpFile.FullName
}

function Install-UserProfile {
    Get-ChildItem -Path './home' |
        Select-Object -ExpandProperty Name |
        Copy-Item -Path $_ -Destination '~/'
}
