param($AppSettingsFile, $FluxApiUrl, $FluxApiKey)

$appSettings = gc $AppSettingsFile | convertfrom-json 
$appSettings.FluxConfig.FluxApiUrl = $FluxApiUrl
$appSettings.FluxConfig.FluxApiKey = $FluxApiKey
$appSettings | convertto-json | set-content $AppSettingsFile
