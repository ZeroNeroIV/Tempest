[Setup]
AppName=Tempest Speedcubing Timer
AppVersion={#AppVersion}
AppPublisher=ZeroNeroIV (Alameen Mahmoud Mohammed Sabbah)
AppPublisherURL=https://github.com/ZeroNeroIV/Tempest
DefaultDirName={autopf}\Tempest
DefaultGroupName=Tempest
OutputDir={#OutputDir}
OutputBaseFilename=Tempest-{#AppVersion}-setup
Compression=lzma2/ultra
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64compatible
SetupIconFile={#IconFile}
UninstallDisplayIcon={app}\Tempest.exe

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Tempest"; Filename: "{app}\Tempest.exe"
Name: "{autodesktop}\Tempest"; Filename: "{app}\Tempest.exe"

[Run]
Filename: "{app}\Tempest.exe"; Description: "Launch Tempest"; Flags: nowait postinstall skipifsilent
