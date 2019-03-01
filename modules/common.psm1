Get-TemporaryDownload([string]$uri) {
    $tmpFile = New-TemporaryFile
    Invoke-WebRequest -Uri $uri -OutFile $tmpFile.FullName

    return $tmpFile.FullName
}

