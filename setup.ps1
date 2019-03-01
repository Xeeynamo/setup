Write-Output "Beginning the set-up"
Get-ChildItem .\modules\*.psm1 | Import-Module -Force

Invoke-TemporaryGitDownload "debloat" "https://github.com/W4RH4WK/Debloat-Windows-10" {
    & ./scripts/block-telemetry.ps1
}

Remove-TempDirectory