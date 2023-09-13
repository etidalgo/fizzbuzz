param($FluxRunnerAppSettings)

$appSettings = gc $FluxRunnerAppSettings | convertfrom-json
$appSettings.ApplicationInsights.ConnectionString = ''
$appSettings | convertto-json | set-content $FluxRunnerAppSettings
