$tempDir = "./.tmp"

function Get-TemporaryDownload([string]$uri) {
    $tmpFile = New-TemporaryFile
    Invoke-WebRequest -Uri $uri -OutFile $tmpFile.FullName

    return $tmpFile.FullName
}

function Unzip([string]$zipfile, [string]$outpath) {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}


function New-TempDirectory {
    if (!(Test-Path -Path $tempDir)) {
        New-Item -ItemType Directory -Force -Path $tempDir
    }
}

function Remove-TempDirectory {
    if (Test-Path -Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
}

function Invoke-TemporaryZipDownload([string]$name, [string]$uri, $action) {
    $outFile = Join-Path $tempDir ($name + ".zip")
    $outDir = Join-Path $tempDir $name

    Invoke-WebRequest -Uri $uri -OutFile $outFile
    Unzip $outFile $outDir
    Push-Location $outDir
    $action
    Pop-Location
}

function Install-UserProfile {
    Get-ChildItem -Path './home' |
        Select-Object -ExpandProperty Name |
        Copy-Item -Path $_ -Destination '~/'
}
