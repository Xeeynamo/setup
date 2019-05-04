Get-ChildItem .\modules\common.psm1 | Import-Module -Force
    
$foobar2000SettingsPath = Join-Path $Env:APPDATA "foobar2000"
$foobar2000UserComponentsPath = Join-Path $foobar2000SettingsPath "user-components"

function Get-PluginNameFromPath([string]$path)
{
    $separator = (($path.LastIndexOf('/'), $path.LastIndexOf('\')) | Measure-Object -Max).Maximum;
    $path = $path.SubString($separator + 1)

    $extensionIndex = $path.IndexOf(".fb2k-component")
    $path.SubString(0, $extensionIndex)
}

function Install-Foobar2000PluginFromUrl([string]$uri)
{
    $fileName = "$(Get-PluginNameFromPath $uri).fb2k-component"
    Invoke-WebRequest -Uri $uri -OutFile $fileName

    Install-Foobar2000PluginFromPath $fileName

    Remove-Item $fileName -Force
}

function Install-Foobar2000PluginFromPath([string]$path)
{
    $outPath = Join-Path $foobar2000UserComponentsPath (Get-PluginNameFromPath $path)
    $zipFile = "$(Get-PluginNameFromPath $path).zip"
    Move-Item $path $zipFile -Force
    Expand-Archive $zipFile -DestinationPath $outPath -Force
    Move-Item $zipFile $path -Force
}