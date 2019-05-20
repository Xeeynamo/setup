$pathVisualStudio2019Community = "./installers/vs_community*.exe"
$pathVisualStudio2019Professional = "./installers/vs_professional*.exe"
$pathVisualStudio2019Enterprise = "./installers/vs_enterprise*.exe"

function Install-VisualStudio([string]$installerPath, [string[]]$components) {
    & $installerPath --wait --passive --norestart ($components | ForEach-Object { @("--add", $_) })
}

function Edit-VisualStudioConfiguration([string]$configPath) {
    $components = Get-VisualStudioComponentsFromConfiguration $configPath
    & $pathVisualStudio2019Enterprise export --config $configPath ($components | ForEach-Object { @("--add", $_) })
}

function Get-VisualStudioComponentsFromConfiguration([string]$configPath) {
    (Get-Content -Path $configPath -Raw | ConvertFrom-Json).components
}

function Join-VisualStudioConfigurations([string[]]$configPaths) {
    # TODO would be nice to pipe everything here...
    $components = @()
    foreach ($configPath in $configPaths) {
        $components += Get-VisualStudioComponentsFromConfiguration $configPath
    }

    $components | Write-Output | Get-Unique
}

function Join-AllVisualStudioConfigurations([string[]]$configDir) {
    Join-VisualStudioConfigurations (Get-ChildItem -Path "." | Select-Object -ExpandProperty Name | Where-Object { $_.Contains(".vsconfig") })
}

function Install-VisualStudioCommunity([string]$components) {
    Install-VisualStudio $pathVisualStudio2019Community $components
}

function Install-VisualStudioProfessional([string]$components) {
    Install-VisualStudio $pathVisualStudio2019Professional $components
}

function Install-VisualStudioEnterprise([string]$components) {
    Install-VisualStudio $pathVisualStudio2019Enterprise $components
}