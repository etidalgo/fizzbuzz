param($PreviousAppSettingsFile, $CurrentAppSettingsFile)

$previousAppSettings = gc $PreviousAppSettingsFile | convertfrom-json 
$currentAppSettings = gc $CurrentAppSettingsFile | convertfrom-json 
$currentAppSettings.FluxConfig.FluxApiUrl = $previousAppSettings.FluxConfig.FluxApiUrl
$currentAppSettings.FluxConfig.FluxApiKey = $previousAppSettings.FluxConfig.FluxApiKey
$currentAppSettings | convertto-json | set-content $CurrentAppSettingsFile
