function Install-StartLayout([string]$fileName) {
    Import-StartLayout -LayoutPath $fileName -MountPath $env:SystemDrive\

    # This will reset the start menu
    Remove-Item -Path "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount"

    # Restart explorer to apply the changes
    Stop-Process -ProcessName "explorer"

}