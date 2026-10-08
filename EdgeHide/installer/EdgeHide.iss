#define MyAppName "EdgeHide"
#define MyAppVersion "0.1.0"
#define MyAppExeName "EdgeHide.exe"

[Setup]
AppId={{C04F47F3-F994-4B77-9B7D-8A9580913A90}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher=EdgeHide
DefaultDirName={localappdata}\Programs\EdgeHide
DefaultGroupName=EdgeHide
PrivilegesRequired=lowest
OutputDir=..\dist
OutputBaseFilename=EdgeHide-Setup-{#MyAppVersion}-win-x64
Compression=lzma
SolidCompression=yes
WizardStyle=modern
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\{#MyAppExeName}
ArchitecturesAllowed=x64compatible

[Languages]
Name: "chinesesimp"; MessagesFile: "ChineseSimplified.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "autostart"; Description: "随 Windows 登录自动启动 EdgeHide"; Flags: unchecked

[Files]
Source: "..\dist\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\EdgeHide"; Filename: "{app}\{#MyAppExeName}"
Name: "{userstartup}\EdgeHide"; Filename: "{app}\{#MyAppExeName}"; Tasks: autostart

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "启动 EdgeHide"; Flags: nowait postinstall skipifsilent
