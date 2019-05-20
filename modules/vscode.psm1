Get-ChildItem .\modules\common.psm1 | Import-Module -Force

function Install-VsCodeExtension([string]$name, [string]$url) {
    Get-DownloadTemporaryFile $name $url {
        & code "--install-extension" $name
    }
}