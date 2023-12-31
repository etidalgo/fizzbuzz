; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define AppId "{E6BC23DA-F14A-4504-934B-BF8013C4DC3D}"
#define SetupReg \
    "Software\Microsoft\Windows\CurrentVersion\Uninstall\" + AppId + "_is1"
#define SetupReg64 \
    "Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" + AppId + "_is1"
#define SetupAppPathReg "Inno Setup: App Path"

#define MyAppName "fizzbuzz"
#define MyAppVersion "1.5"
#define MyAppPublisher "fizzbuzz"
#define MyAppExeName "FizzBuzz.exe"

#define AppSettingsFile 'appSettings.json'
#define FluxRunnerAppSettingsFile 'flux.appsettings.json'

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
; Two curly brackets for directive
AppId={#StringChange(AppId, '{', '{{')}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DisableDirPage=yes
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputBaseFilename=fizzbuzzinstaller
Compression=lzma
SetupLogging=yes
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\FizzBuzz\bin\Release\net6.0\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\FizzBuzz\bin\Release\net6.0\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: ".\Installer-Tasks\*"; Flags: dontcopy ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: postinstall runhidden

[Code]
var
IsUpgradeCached: Boolean;
BackupAppSettingsFile: String;
BackupFluxRunnerAppSettingsFile: String;

function IsUpgrade: Boolean;
var
  S: string;
begin
  Result :=
    RegQueryStringValue(HKLM, '{#SetupReg}', '{#SetupAppPathReg}', S) or
    RegQueryStringValue(HKCU, '{#SetupReg}', '{#SetupAppPathReg}', S);
end;

function BoolToStr(Value: Boolean): String;
begin
  if Value then
    Result := 'True'
  else
    Result := 'False';
end;

function InitializeSetup(): Boolean;
var
    FOInstance: String;
    FOUrl: String;
    FOKey: String;
begin
    IsUpgradeCached := IsUpgrade();
    Log('IsUpgrade: '+BoolToStr(IsUpgradeCached));
    Log('Reg check {#SetupReg}');

    { Validate parameters }
    FOInstance := ExpandConstant('{param:FOInstance|default}');
    FOUrl := ExpandConstant('{param:FOUrl|default}');
    FOKey := ExpandConstant('{param:FOKey|default}');

    Log('Command line parameters');
    Log('- FOInstance: '+FOInstance);
    Log('- FOUrl: '+FOUrl);
    Log('- FOKey: '+FOKey);

    if ((FOInstance = 'prod') or (FOInstance = 'default') or (FOInstance = 'qa') or (FOInstance = 'dev')) then
    begin
        Result := true;
        exit;
    end;

    if (FOInstance = 'custom') then
    begin
        if ((FOUrl = 'default') or (FOKey = 'default')) then
        begin
            MsgBox('For custom FluxOnline instances, FOUrl and FOKey must be set.', mbError, MB_OK);
            Result := false;
        end else
        begin
            Result := true;
        end;

        exit;
    end;

    MsgBox('FOInstance may be set to prod|qa|dev|custom. FOInstance is optional and defaults to prod. If it is set to custom, then FOUrl and FOKey must be specified. ', mbError, MB_OK);
    Result := false;
end;

procedure ConfigureFluxOnline();
var
    ResultCode : Integer;

    FOInstance: String;

    fluxOnlineUrl: String;
    fluxOnlineApiKey: String;

    tmp: String;
    appfolder: String;
    appSettingsFile: String;
    updateAppSettings: String;
begin
    Log('Scanning parameters for FluxOnline configuration');
    { FluxOnline values, tied to parameters }
    FOInstance := ExpandConstant('{param:FOInstance|default}');

    if (FOInstance = 'default') then
    begin
        Log('Using default FluxOnline configuration');
        exit;
    end;

    { parameters were validated in InitializeSetup() }
    fluxOnlineUrl := ExpandConstant('{param:FOUrl|default}');
    fluxOnlineApiKey := ExpandConstant('{param:FOKey|default}');

    Log('Configuring FluxOnline');
    Log('- FOInstance: '+ FOInstance);
    Log('- Url: '+ fluxOnlineUrl);
    Log('- Api Key: '+ fluxOnlineApiKey);

    appfolder := ExpandConstant('{app}');
    appSettingsFile := appfolder + '\appsettings.json';
    tmp := ExpandConstant('{tmp}');
    ExtractTemporaryFiles('*.p*1');
    ExtractTemporaryFiles('*FOConfigurations.json');

    updateAppSettings := tmp + '\ApplyFluxOnlineConfiguration.ps1';
    Log('Preparing to update app settings.');
    Exec('powershell.exe',
        '-ExecutionPolicy bypass -File "' + updateAppSettings + '" ' +
        '-AppSettingsFile "' + appSettingsFile + '" ' +
        '-FluxConfiguration "' + FOInstance + '" ' +
        '-FluxApiUrl "' + fluxOnlineUrl + '" ' +
        '-FluxApiKey "'+ fluxOnlineApiKey +'" ',
        '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure DisableFluxAppInsights();
var
    ResultCode : Integer;
    fluxAppSettingsFile: String;
    disableAppInsights: String;
begin
    if(ExpandConstant('{param:DisableAppInsights|false}') <> 'true') then exit;

    Log('Disabling Flux App Insights');
    fluxAppSettingsFile := ExpandConstant('{app}') + '\flux.appsettings.json';

    ExtractTemporaryFiles('*.p*1');
    disableAppInsights := ExpandConstant('{tmp}') + '\DisableFluxRunnerAppInsights.ps1';
    Exec('powershell.exe',
        '-ExecutionPolicy bypass -File "' + disableAppInsights + '" ' +
        '-FluxRunnerAppSettings "' + fluxAppSettingsFile + '" ',
        '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

end;

procedure BackupAppSettings();
var
    appSettingsFile: String;
    fluxRunnerAppSettingsFile: String;
begin
    BackupAppSettingsFile := ExpandConstant('{tmp}') + '\appsettings.json';
    appSettingsFile := ExpandConstant('{app}') + '\appsettings.json';

    BackupFluxRunnerAppSettingsFile := ExpandConstant('{tmp}') + '\flux.appsettings.json';
    fluxRunnerAppSettingsFile := ExpandConstant('{app}') + '\flux.appsettings.json';

    Log('Back up appSettings from ' + appSettingsFile + ' to ' + BackupAppSettingsFile);
    FileCopy(appSettingsFile, BackupAppSettingsFile, false);
    FileCopy(fluxRunnerAppSettingsFile, BackupFluxRunnerAppSettingsFile, false);
end;

procedure TransferAppSettings();
var
    ResultCode : Integer;

    appSettingsFile: String;
    fluxRunnerAppSettingsFile: String;

    transferFluxOnlineSettings: String;
    transferFluxRunnerSettings: String;
begin
    appSettingsFile := ExpandConstant('{app}') + '\appsettings.json';
    fluxRunnerAppSettingsFile := ExpandConstant('{app}') + '\flux.appsettings.json';
    Log('Transferring FluxOnline settings from ' + BackupAppSettingsFile + ' to ' + appSettingsFile);
    Log('Transferring FluxRunner settings from ' + BackupFluxRunnerAppSettingsFile + ' to ' + fluxRunnerAppSettingsFile);

    Log('Preparing to transfer FluxOnline settings.');
    ExtractTemporaryFiles('*.p*1');
    transferFluxOnlineSettings := ExpandConstant('{tmp}') + '\TransferAppSettings.ps1';
    Exec('powershell.exe',
        '-ExecutionPolicy bypass -File "' + transferFluxOnlineSettings + '" ' +
        '-PreviousAppSettingsFile "' + BackupAppSettingsFile + '" ' +
        '-CurrentAppSettingsFile "' + appSettingsFile + '" ',
        '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

    transferFluxRunnerSettings := ExpandConstant('{tmp}') + '\TransferFluxRunnerAppSettings.ps1';
    Exec('powershell.exe',
        '-ExecutionPolicy bypass -File "' + transferFluxRunnerSettings + '" ' +
        '-PreviousFluxRunnerAppSettingsFile "' + BackupFluxRunnerAppSettingsFile + '" ' +
        '-CurrentFluxRunnerAppSettingsFile "' + fluxRunnerAppSettingsFile + '" ',
        '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin

  if ((CurStep = ssInstall) and (IsUpgradeCached = true)) then BackupAppSettings();

  if (CurStep = ssPostInstall) then
  begin
    if(IsUpgradeCached = false) then
    begin
        ConfigureFluxOnline();
        DisableFluxAppInsights();
    end
    else TransferAppSettings();
  end;
end;

