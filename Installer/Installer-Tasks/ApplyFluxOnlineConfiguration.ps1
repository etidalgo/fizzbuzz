param($AppSettingsFile, $FluxConfiguration, $FluxApiUrl, $FluxApiKey)

if($FluxConfiguration -eq 'default') {
    return;
}

if ($FluxConfiguration -eq 'qa' -or $FluxConfiguration -eq 'dev') {
    $configurations = gc "$PSScriptRoot/FOConfigurations.json" | convertfrom-json

    $configuration = $configurations."FluxConfig_$FluxConfiguration"
    $FluxApiUrl = $configuration.FluxApiUrl
    $FluxApiKey = $configuration.FluxApiKey
} else {
    if ($FluxConfiguration -ne 'custom') {
        return;
    }
}

$appSettings = gc $AppSettingsFile | convertfrom-json 
$appSettings.FluxConfig.FluxApiUrl = $FluxApiUrl
$appSettings.FluxConfig.FluxApiKey = $FluxApiKey
$appSettings | convertto-json | set-content $AppSettingsFile

# .\UpdateAppSettings.ps1 -AppSettingsFile $AppSettingsFile -FluxApiUrl $FluxApiUrl -FluxApiKey $FluxApiKey