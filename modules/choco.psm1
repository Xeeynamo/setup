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

function Install-ChocoPackages([ChocoPackage[]]$packages, [string]$priority) {
    $packages |
        Where-Object { $_.Priority -eq $priority } |
        ForEach-Object {
            Write-Host "Installing" $_.Name
            & choco install $_.Name -y
        }
}