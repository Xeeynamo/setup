Get-ChildItem .\modules\common.psm1 | Import-Module -Force

function Install-VsCodeExtensionFromUrl([string]$name, [string]$url) {
    Get-DownloadTemporaryFile $name $url {
        & code "--install-extension" $name
    }
}

function Install-VsCodeExtension([string]$name) {
    & code "--install-extension" $name
}
