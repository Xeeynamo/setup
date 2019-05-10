class ChocoPackage {
    [string] $priority
    [string] $name
}

function Get-ChocoPackages([string]$fileName) {
    Get-Content $fileName |
        # Ignore comments
        Where-Object { $_[0] -ne '#' -and $_.Length -gt 0 } |
        # Group packages by priority and throw a warning if there is no priority assigned
        Foreach-Object {
            # The first character must be the priority
            $priority = $_[0]
            if ($priority -notmatch "^\d$") {
                Write-Host "The package $_ will be ignored"
                #return $null
            }

            # The second character must be a space
            if ($_[1] -ne ' ') {
                Write-Host "The package $_ is invalid"
                #return $null
            }

            return New-Object -TypeName ChocoPackage -Property @{
                Priority = $priority
                Name = $_.Substring(2)
            }
        }
}

function Get-IsChocoPackageInstalled([string]$packageName) {
    (choco list --lo | Where-Object { $_.Contains("$packageName ") }).Count -gt 0 
}

function Install-ChocoPackage([string]$packageName, [switch]$force) {
    if ($force) {
        & choco install $packageName --confirm --limit-output --force
    }
    else {
        & choco install $packageName --confirm --limit-output
    }
}

function Install-ChocoPackageIfNotInstalled([string]$packageName) {
    $isInstalled = Get-IsChocoPackageInstalled $packageName
    if ($isInstalled -eq $false) {
        Install-ChocoPackage $packageName
    }
}

function Uninstall-ChocoPackage([string]$packageName) {
    & choco uninstall $packageName --confirm --limit-output
}

function Install-ChocoPackages([ChocoPackage[]]$packages, [string]$priority) {
    $packages |
        Where-Object { $_.Priority -eq $priority } |
        ForEach-Object {
            Write-Host "Installing" $_.Name
            Install-ChocoPackage $_.Name
        }

    # Reset-PathEnvironment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
}