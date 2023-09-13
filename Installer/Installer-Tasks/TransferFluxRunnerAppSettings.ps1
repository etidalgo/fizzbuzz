param($PreviousFluxRunnerAppSettingsFile, $CurrentFluxRunnerAppSettingsFile)

$previousFluxRunnerAppSettings = gc $PreviousFluxRunnerAppSettingsFile | convertfrom-json 
$currentFluxRunnerAppSettings = gc $CurrentFluxRunnerAppSettingsFile | convertfrom-json 
$currentFluxRunnerAppSettings.ApplicationInsights.ConnectionString  = $previousFluxRunnerAppSettings.ApplicationInsights.ConnectionString 
$currentFluxRunnerAppSettings | convertto-json | set-content $CurrentFluxRunnerAppSettingsFile
